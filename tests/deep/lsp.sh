#!/usr/bin/env bash
# Deep e2e, lsp: python LSP keymaps, diagnostics, formatting and editing.
# Run alone: ./tests/deep/lsp.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup lsp
deep_boot backend/core/services.py

# ---------------------------------------------------------------- lsp
# by name: ruff attaches first, and a picker opened before pyright is there
# answers "server does not support textDocument/documentSymbol"
wait_lexpr "pyright attaches to the backend file" \
  '#vim.lsp.get_clients({ bufnr = vim.fn.bufnr("services.py"), name = "pyright" }) > 0 and 1 or 0' 40
keys Space f o
wait_lexpr "keymap <leader>fo opens the symbol picker" "$(win_with_ft TelescopePrompt)" 15
keys Escape Escape
goto_line 9
cursor_on double
keys g d
wait_lexpr "keymap gd jumps to the definition of double()" 'vim.fn.line(".") == 1 and 1 or 0' 15
goto_line 9
cursor_on double
keys K
wait_lexpr "keymap K opens the hover float" \
  '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then return 1 end end return 0 end)()' 15
keys Escape
keys g r
wait_lexpr "keymap gr fills the quickfix with references" '#vim.fn.getqflist() > 0 and 1 or 0' 15
keys Escape ":cclose" Enter
keys g i
wait_lexpr "keymap gi runs without wedging nvim" "1" 10
goto_line 9
cursor_on double
keys Space g d
wait_lexpr "keymap <leader>gd opens the definition in a split" '#vim.api.nvim_tabpage_list_wins(0) >= 2 and 1 or 0' 15
open_file backend/core/services.py
goto_line 9
cursor_on double
keys Space g r
wait_lexpr "keymap <leader>gr opens references in telescope" "$(win_with_ft TelescopePrompt)" 15
keys Escape Escape
open_file backend/core/services.py
goto_line 1
cursor_on double
keys Space r n
keys "renamed_double" Enter
wait_lexpr "keymap <leader>rn renames the symbol across the buffer" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match("renamed_double") then return 1 end end return 0 end)()' 20
keys Escape "u"
keys Space c a
wait_lexpr "keymap <leader>ca runs without wedging nvim" "1" 10
keys Escape Escape

# ---------------------------------------------------------------- diagnostics
open_file backend/core/legacy.py
wait_lexpr "ruff reports the unused imports in legacy.py" \
  '#vim.diagnostic.get(0) > 0 and 1 or 0' 60
goto_line 8
keys "[" d
wait_lexpr "keymap [d jumps back to a diagnostic" 'vim.fn.line(".") <= 2 and 1 or 0'
goto_line 8
keys Space g p
wait_lexpr "keymap <leader>gp jumps back to a diagnostic" 'vim.fn.line(".") <= 2 and 1 or 0'
goto_line 1
keys "]" d
wait_lexpr "keymap ]d jumps to the next diagnostic" 'vim.fn.line(".") == 2 and 1 or 0'
goto_line 1
keys Space g n
wait_lexpr "keymap <leader>gn jumps to the next diagnostic" 'vim.fn.line(".") == 2 and 1 or 0'
goto_line 1
keys Space g f
wait_lexpr "keymap <leader>gf opens the diagnostic float" \
  '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then return 1 end end return 0 end)()' 10
keys Escape
keys Space E
wait_lexpr "keymap <leader>E opens a focusable diagnostic float" \
  '(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then return 1 end end return 0 end)()' 10
keys Escape

# ---------------------------------------------------------------- editing
open_file backend/core/services.py
keys G o "value    =    1" Escape
keys Space F
wait_lexpr "keymap <leader>F reformats the buffer with ruff" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l == "value = 1" then return 1 end end return 0 end)()' 20
keys Escape ":1" Enter
keys Space S
wait_screen "keymap <leader>S prefills the substitute command" ":%s/" 10
keys Escape
# an Escape and an "O" in one burst reach nvim as "ESC O", the SS3 prefix of a
# terminal key code, and the O command plus the text after it are lost
wait_lexpr "the substitute prompt is cancelled" 'vim.api.nvim_get_mode().mode == "n" and 1 or 0' 10
keys "O" "spaced    =    2" Escape
keys "V" Space F
wait_lexpr "keymap <leader>F formats a visual selection" \
  '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l == "spaced = 2" then return 1 end end return 0 end)()' 15
keys Escape ":e!" Enter

deep_finish
