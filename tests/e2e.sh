#!/usr/bin/env bash
# End-to-end suite: drives a REAL nvim TUI inside tmux with genuine
# keystrokes (terminal -> PTY -> nvim), asserting via RPC state
# (--remote-expr) and the actually rendered screen (capture-pane).
# Run: ./tests/e2e.sh   Exits 0 when every check passes.
set -uo pipefail

S="nvim-e2e-$$"
PROJ="$(mktemp -d)"
SOCK="$PROJ/nvim.sock"

cleanup() {
  tmux kill-session -t "$S" 2>/dev/null || true
  rm -rf "$PROJ"
}
trap cleanup EXIT

# scratch project: git repo so gitsigns/git-blame have something real
cd "$PROJ" || exit 1
git init -q
git -c user.email=e2e@test -c user.name=e2e commit -q --allow-empty -m init
cat > app.py <<'EOF'
x = 1
y = x + 1
print(y)
EOF
git add app.py
git -c user.email=e2e@test -c user.name=e2e commit -q -m "add app.py"

PASS=0
FAIL=0
declare -a RESULTS

ok()  { RESULTS+=("PASS  $1"); PASS=$((PASS + 1)); }
bad() { RESULTS+=("FAIL  $1  ($2)"); FAIL=$((FAIL + 1)); }

# every RPC call gets its own watchdog: a wedged nvim (e.g. stuck on a
# hit-enter prompt) must fail the check, never hang the suite
expr_() { perl -e 'alarm shift; exec @ARGV' 5 nvim --server "$SOCK" --remote-expr "$1" 2>/dev/null; }
# lua snippets must use double quotes internally and evaluate to 1 (pass) or 0
lexpr() { expr_ "luaeval('$1')"; }
keys() { tmux send-keys -t "$S" "$@"; }
screen() { tmux capture-pane -pt "$S"; }

# dismiss hit-enter prompts the way a real user does, but record what
# was on screen so the underlying message still fails the suite
declare -a PROMPTS
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
    if [ "$r" = "1" ]; then ok "$name"; return 0; fi
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
    if screen | grep -q "$pat"; then ok "$name"; return 0; fi
    sleep 0.5
  done
  bad "$name" "pattern '$pat' never rendered"
  return 1
}

# ---- boot a real nvim TUI ----
tmux new-session -d -s "$S" -x 220 -y 60 "nvim --listen '$SOCK' app.py"
wait_lexpr "nvim TUI up and responding to RPC" "1" 15

# ---- rendering: statusline + editor tabs actually painted ----
wait_screen "lualine renders (mode in statusline)" "NORMAL" 15
wait_screen "bufferline renders (file tab on top row)" "app.py"

# ---- real keystrokes: <Space>ee toggles nvim-tree ----
keys Space e e
wait_lexpr "keymap <leader>ee opens nvim-tree window" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"NvimTree\" then return 1 end end return 0 end)()"
wait_screen "nvim-tree panel visible on screen" "app.py"
keys Space e e
wait_lexpr "keymap <leader>ee closes nvim-tree again" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"NvimTree\" then return 0 end end return 1 end)()"

# ---- LSP attaches to the real buffer ----
wait_lexpr "LSP client attaches to app.py" \
  "#vim.lsp.get_clients({ bufnr = vim.fn.bufnr(\"app.py\") }) > 0 and 1 or 0" 30

# ---- gitsigns attaches in a real repo, sees a real edit ----
wait_lexpr "gitsigns attaches (repo status available)" \
  "vim.b[vim.fn.bufnr(\"app.py\")].gitsigns_status_dict ~= nil and 1 or 0" 15
keys g g c c "x = 99" Escape
wait_lexpr "gitsigns marks the modified hunk" \
  "#require(\"gitsigns\").get_hunks(vim.fn.bufnr(\"app.py\")) > 0 and 1 or 0" 15
keys ":e!" Enter

# ---- completion popup appears while typing ----
# settle after the :e! above: typing before the LSP re-syncs the reloaded
# buffer means blink gets an empty first response and never re-triggers
wait_lexpr "LSP re-attached after buffer reload" \
  "#vim.lsp.get_clients({ bufnr = vim.fn.bufnr(\"app.py\") }) > 0 and 1 or 0" 15
sleep 2
keys G o "imp"
wait_lexpr "blink.cmp popup opens while typing" \
  "require(\"blink.cmp\").is_visible() and 1 or 0" 15
keys Escape ":e!" Enter

# ---- telescope opens via real keys, finds the file ----
keys Space f f
wait_lexpr "keymap <leader>ff opens telescope prompt" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"TelescopePrompt\" then return 1 end end return 0 end)()"
keys "app"
wait_screen "telescope narrows to app.py" "app.py"
keys Escape Escape
wait_lexpr "telescope closes on Escape" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"TelescopePrompt\" then return 0 end end return 1 end)()"

# ---- full DAP session: breakpoint -> run -> stop -> UI -> terminate ----
keys "2" G Space b b
wait_lexpr "keymap <leader>bb sets a breakpoint" \
  "(function() local n = 0 for _, bp in pairs(require(\"dap.breakpoints\").get()) do n = n + #bp end return n == 1 and 1 or 0 end)()"
keys Space d c
wait_screen "dap prompts for a launch configuration" "Launch file" 20
keys 1 Enter
wait_lexpr "debugpy session starts and stops at the breakpoint" \
  "(function() local s = require(\"dap\").session() return (s and s.stopped_thread_id) and 1 or 0 end)()" 30
wait_lexpr "dap-ui opens automatically on session start" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"dapui_scopes\" then return 1 end end return 0 end)()" 15
keys Space d t
wait_lexpr "keymap <leader>dt terminates the session" \
  "require(\"dap\").session() == nil and 1 or 0" 20
wait_lexpr "dap-ui closes after termination" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"dapui_scopes\" then return 0 end end return 1 end)()" 15

# ---- markdown-preview registers for a real .md buffer ----
keys ":e note.md" Enter
wait_lexpr "markdown-preview command available on .md" \
  "vim.fn.exists(\":MarkdownPreview\") == 2 and 1 or 0" 15

# ---- no LSP spawn failures anywhere in the session ----
sleep 2
dismiss_prompts
if expr_ 'execute("messages")' | grep -qi "failed\|error"; then
  bad "no errors in :messages" "$(expr_ 'execute("messages")' | grep -i 'failed\|error' | head -2 | tr '\n' ' ')"
else
  ok "no errors in :messages"
fi
if [ "${#PROMPTS[@]}" -gt 0 ]; then
  bad "no hit-enter prompts during the run" "${PROMPTS[0]}"
else
  ok "no hit-enter prompts during the run"
fi

# ---- clean shutdown ----
keys ":qa!" Enter
for ((i = 0; i < 20; i++)); do
  tmux has-session -t "$S" 2>/dev/null || break
  sleep 0.5
done
if tmux has-session -t "$S" 2>/dev/null; then
  bad "nvim quits cleanly" "tmux session still alive"
else
  ok "nvim quits cleanly"
fi

printf '%s\n' "${RESULTS[@]}"
echo
echo "$PASS/$((PASS + FAIL)) e2e checks passed"
[ "$FAIL" -eq 0 ]
