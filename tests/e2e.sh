#!/usr/bin/env bash
# E2E suite, real nvim TUI driven through tmux: ./tests/e2e.sh
set -uo pipefail

# resolve before the cd below, or sourcing breaks from the scratch project
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$HERE/tmux_lib.sh"

S="nvim-e2e-$$"
PROJ="$(mktemp -d)"
SOCK="$PROJ/nvim.sock"

cleanup() {
  tmux kill-session -t "$S" 2>/dev/null || true
  rm -rf "$PROJ"
}
trap cleanup EXIT

cd "$PROJ" || exit 1
git init -q
git -c user.email=e2e@test -c user.name=e2e commit -q --allow-empty -m init
cat >app.py <<'EOF'
x = 1
y = x + 1
print(y)
EOF
git add app.py
git -c user.email=e2e@test -c user.name=e2e commit -q -m "add app.py"

tmux new-session -d -s "$S" -x 220 -y 60 "nvim --listen '$SOCK' app.py"
wait_lexpr "nvim TUI up and responding to RPC" "1" 15

wait_screen "lualine renders (mode in statusline)" "NORMAL" 15
wait_screen "bufferline renders (file tab on top row)" "app.py"

keys Space e e
wait_lexpr "keymap <leader>ee opens nvim-tree window" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"NvimTree\" then return 1 end end return 0 end)()"
# "Project", not "app.py": the bufferline tab already shows app.py, so it never fails
wait_screen "nvim-tree panel visible on screen" "Project"
keys Space e e
wait_lexpr "keymap <leader>ee closes nvim-tree again" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"NvimTree\" then return 0 end end return 1 end)()"

wait_lexpr "LSP client attaches to app.py" \
  "#vim.lsp.get_clients({ bufnr = vim.fn.bufnr(\"app.py\") }) > 0 and 1 or 0" 30

wait_lexpr "gitsigns attaches (repo status available)" \
  "vim.b[vim.fn.bufnr(\"app.py\")].gitsigns_status_dict ~= nil and 1 or 0" 15
keys g g c c "x = 99" Escape
wait_lexpr "gitsigns marks the modified hunk" \
  "#require(\"gitsigns\").get_hunks(vim.fn.bufnr(\"app.py\")) > 0 and 1 or 0" 15
keys ":e!" Enter

# let LSP re-sync after :e!, else blink gets an empty first response and never retriggers
wait_lexpr "LSP re-attached after buffer reload" \
  "#vim.lsp.get_clients({ bufnr = vim.fn.bufnr(\"app.py\") }) > 0 and 1 or 0" 15
sleep 2
keys G o "imp"
wait_lexpr "blink.cmp popup opens while typing" \
  "require(\"blink.cmp\").is_visible() and 1 or 0" 15
keys Escape ":e!" Enter

keys Space f f
wait_lexpr "keymap <leader>ff opens telescope prompt" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"TelescopePrompt\" then return 1 end end return 0 end)()"
keys "app"
# "> app", not "app.py": the bufferline tab would pass even if telescope rendered nothing
wait_screen "telescope prompt shows the typed query" "> app"
keys Escape Escape
wait_lexpr "telescope closes on Escape" \
  "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == \"TelescopePrompt\" then return 0 end end return 1 end)()"

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

keys ":e note.md" Enter
wait_lexpr "markdown-preview command available on .md" \
  "vim.fn.exists(\":MarkdownPreview\") == 2 and 1 or 0" 15

sleep 2
dismiss_prompts
# liveness first: a dead nvim answers "" and that would read as "no errors"
if [ "$(expr_ '1')" != "1" ]; then
  bad "no errors in :messages" "nvim unreachable, cannot read :messages"
else
  msgs="$(expr_ 'execute("messages")')"
  if echo "$msgs" | grep -qi "failed\|error"; then
    bad "no errors in :messages" "$(echo "$msgs" | grep -i 'failed\|error' | head -2 | tr '\n' ' ')"
  else
    ok "no errors in :messages"
  fi
fi
if [ "${#PROMPTS[@]}" -gt 0 ]; then
  bad "no hit-enter prompts during the run" "${PROMPTS[0]}"
else
  ok "no hit-enter prompts during the run"
fi

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

summary e2e
