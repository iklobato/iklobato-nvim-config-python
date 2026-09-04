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
