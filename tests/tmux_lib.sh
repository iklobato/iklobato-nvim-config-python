#!/usr/bin/env bash
# Shared driver for the tmux suites: real keystrokes go terminal -> PTY -> nvim,
# assertions read back real state over RPC (--remote-expr) and the actually
# rendered screen (capture-pane).
#
# The caller sets S (tmux session name) and SOCK (nvim --listen socket) before
# sourcing this, then uses wait_lexpr / wait_screen / keys and ends with summary.

PASS=0
FAIL=0
declare -a RESULTS
declare -a PROMPTS

# printed as they happen, not only in the summary: a suite that wedges halfway
# still has to say how far it got
ok() {
  RESULTS+=("PASS  $1")
  PASS=$((PASS + 1))
  DEAD_RPC=0
  [ -n "${VERBOSE:-}" ] && echo "PASS  $1"
  return 0
}

bad() {
  RESULTS+=("FAIL  $1  ($2)")
  FAIL=$((FAIL + 1))
  [ -n "${VERBOSE:-}" ] && echo "FAIL  $1  ($2)"
  return 0
}

# once nvim stops answering RPC every later check just burns its timeout, so
# stop and say so instead of grinding through the rest of the suite
DEAD_RPC=0
give_up_if_wedged() {
  [ -n "$(expr_ '1')" ] && return 0
  DEAD_RPC=$((DEAD_RPC + 1))
  [ "$DEAD_RPC" -lt 3 ] && return 0
  echo
  echo "nvim stopped answering RPC after: ${RESULTS[-1]:-<no checks yet>}"
  echo "last screen:"
  screen | tail -12
  summary "${SUITE_LABEL:-e2e}"
  exit 1
}

# every RPC call gets its own watchdog: a wedged nvim (e.g. stuck on a
# hit-enter prompt) must fail the check, never hang the suite
expr_() { perl -e 'alarm shift; exec @ARGV' 5 nvim --server "$SOCK" --remote-expr "$1" 2>/dev/null; }
# lua snippets must use double quotes internally and evaluate to 1 (pass) or 0
lexpr() { expr_ "luaeval('$1')"; }
keys() { tmux send-keys -t "$S" "$@"; }
screen() { tmux capture-pane -pt "$S"; }

# dismiss hit-enter prompts the way a real user does, but record what
# was on screen so the underlying message still fails the suite
dismiss_prompts() {
  if screen | grep -q "Press ENTER"; then
    PROMPTS+=("$(screen | tail -3 | tr '\n' ' ')")
    keys Enter
  fi
}

wait_lexpr() { # name, lua-expr-evaluating-to-1, timeout-seconds
  local name=$1 e=$2 t=${3:-10} r=""
  local tries=$((t * 2))
  for ((i = 0; i < tries; i++)); do
    r=$(lexpr "$e" || true)
    if [ "$r" = "1" ]; then
      ok "$name"
      return 0
    fi
    dismiss_prompts
    sleep 0.5
  done
  bad "$name" "expr=$e last=$r"
  return 1
}

wait_screen() { # name, grep-pattern, timeout-seconds
  local name=$1 pat=$2 t=${3:-10}
  local tries=$((t * 2))
  for ((i = 0; i < tries; i++)); do
    if screen | grep -q "$pat"; then
      ok "$name"
      return 0
    fi
    sleep 0.5
  done
  bad "$name" "pattern '$pat' never rendered"
  give_up_if_wedged
  return 1
}

summary() { # label
  printf '%s\n' "${RESULTS[@]}"
  echo
  echo "$PASS/$((PASS + FAIL)) ${1:-e2e} checks passed"
  [ "$FAIL" -eq 0 ]
}

# ---------------------------------------------------------------- deep suite
# Each script in tests/deep/ drives one area in its own nvim over the realistic
# monorepo: deep_setup <area>, deep_boot <file>, its checks, deep_finish. A
# fresh nvim per area means one broken area cannot cascade into the next, and
# one area can be rerun alone in a couple of minutes.

# the servers are started inside subshells, so $! is the subshell and killing it
# leaves the real python/node child holding its port.
# Another listener on *:8000 (a docker container) also answers 127.0.0.1:8000,
# so "got a response" is never proof that the fixture's server is the one up:
# every probe checks for the fixture's own body.
stop_django() {
  pkill -f "manage.py runserver" 2>/dev/null
  for _ in $(seq 1 20); do
    curl -s -m 1 http://127.0.0.1:8000/api/totals/ | grep -q '"total"' || return 0
    sleep 1
  done
  return 0
}

deep_cleanup() {
  stop_django
  pkill -f "$MONO/frontend.*vite" 2>/dev/null
  pkill -f "npm run dev" 2>/dev/null
  pkill -f "asgi_demo:app" 2>/dev/null
  tmux kill-session -t "$S" 2>/dev/null
  rm -rf "$(dirname "$SOCK")"
  return 0
}

deep_setup() { # area
  MONO="${XDG_CACHE_HOME:-$HOME/.cache}/nvim-e2e-deep/monorepo"
  S="nvim-deep-$1-$$"
  SUITE_LABEL="deep/$1"
  SOCK="$(mktemp -d)/nvim.sock"
  trap deep_cleanup EXIT
  "$TESTS/fixtures/monorepo.sh" "$MONO" || exit 1
  # the python adapter follows VIRTUAL_ENV, and the fixture's venv is the one
  # with django and a working pytest
  export VIRTUAL_ENV="$MONO/backend/.venv"
  export PATH="$VIRTUAL_ENV/bin:$PATH"
}

deep_boot() { # file, relative to the monorepo root
  cd "$MONO" || exit 1
  tmux new-session -d -s "$S" -x 220 -y 60 "nvim --listen '$SOCK' $1"
  wait_lexpr "nvim boots on the monorepo and answers RPC" "1" 20
  wait_screen "lualine renders" "NORMAL" 15
}

deep_finish() {
  sleep 2
  dismiss_prompts
  if expr_ 'execute("messages")' | grep -qiE "E[0-9]{3}:|stack traceback"; then
    bad "no vim errors in :messages" "$(expr_ 'execute("messages")' | grep -iE "E[0-9]{3}:|stack traceback" | head -2 | tr '\n' ' ')"
  else
    ok "no vim errors in :messages"
  fi
  if [ "${#PROMPTS[@]}" -gt 0 ]; then
    bad "no hit-enter prompts during the run" "${PROMPTS[0]}"
  else
    ok "no hit-enter prompts during the run"
  fi
  keys Escape ":qa!" Enter
  for _ in $(seq 1 20); do
    tmux has-session -t "$S" 2>/dev/null || break
    sleep 0.5
  done
  if tmux has-session -t "$S" 2>/dev/null; then
    bad "nvim quits cleanly" "tmux session still alive"
  else
    ok "nvim quits cleanly"
  fi
  summary "$SUITE_LABEL"
}

# focus a window by filetype. The keys sent into the panel afterwards are real;
# only the jump is scripted, because <C-w> hops through a 5-window layout are
# too brittle to assert on.
focus_ft() {
  lexpr '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "'"$1"'" then vim.api.nvim_set_current_win(w) return 1 end end return 0 end)()' >/dev/null
}

# a phase that starts from whatever the previous one left behind cascades its
# failures, so every file switch closes floats and splits and is asserted
open_file() { # relative-path
  local base=${1##*/}
  keys Escape Escape
  keys Escape ":silent! cclose" Enter
  keys Escape ":silent! only" Enter
  keys Escape ":e $1" Enter
  wait_lexpr "opened $base" 'vim.fn.expand("%:t") == "'"$base"'" and 1 or 0' 15
}

goto_line() { keys Escape ":$1" Enter; }

# f/w counting breaks the moment a fixture line changes; searching does not
cursor_on() { # word
  keys Escape "0"
  keys Escape "/$1" Enter
  keys Escape
  wait_lexpr "cursor sits on $1" 'vim.fn.expand("<cword>") == "'"$1"'" and 1 or 0' 10
}

bp_count() {
  echo '(function() local n = 0 for _, bp in pairs(require("dap.breakpoints").get()) do n = n + #bp end return n end)()'
}

session_stopped() {
  echo '(function() local s = require("dap").session() return (s and s.stopped_thread_id and s.current_frame) and 1 or 0 end)()'
}

frame_line() {
  echo '(function() local s = require("dap").session() return (s and s.current_frame and s.current_frame.line == '"$1"') and 1 or 0 end)()'
}

frame_name() {
  echo '(function() local s = require("dap").session() return (s and s.current_frame and s.current_frame.name:match("'"$1"'")) and 1 or 0 end)()'
}

no_session() { echo 'require("dap").session() == nil and 1 or 0'; }

win_with_ft() {
  echo '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "'"$1"'" then return 1 end end return 0 end)()'
}
