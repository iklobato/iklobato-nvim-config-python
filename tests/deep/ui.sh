#!/usr/bin/env bash
# Deep e2e, ui: statusline, motions, windows, tabs, explorer, buffers, save and quit keymaps.
# Run alone: ./tests/deep/ui.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup ui
deep_boot backend/core/services.py

# ---------------------------------------------------------------- motions
goto_line 2
keys L
wait_lexpr "keymap L jumps to end of line" 'vim.fn.col(".") >= 22 and 1 or 0'
keys H
wait_lexpr "keymap H jumps to first non-blank" 'vim.fn.col(".") == 5 and 1 or 0'
goto_line 9
keys "0"
keys B
wait_lexpr "keymap B moves a word forward" 'vim.fn.col(".") > 1 and 1 or 0'
keys Escape '$'
keys W
wait_lexpr "keymap W moves a word back" 'vim.fn.col(".") < vim.fn.col("$") - 1 and 1 or 0'
goto_line 7
keys Space j
wait_lexpr "keymap <leader>j moves down a screen line" 'vim.fn.line(".") == 8 and 1 or 0'
keys Space k
wait_lexpr "keymap <leader>k moves up a screen line" 'vim.fn.line(".") == 7 and 1 or 0'

# ---------------------------------------------------------------- windows
keys Space s v
wait_lexpr "keymap <leader>sv splits vertically" '#vim.api.nvim_tabpage_list_wins(0) == 2 and 1 or 0'
keys Space s h
wait_lexpr "keymap <leader>sh splits horizontally" '#vim.api.nvim_tabpage_list_wins(0) == 3 and 1 or 0'
keys Space s e
wait_lexpr "keymap <leader>se equalizes without closing windows" '#vim.api.nvim_tabpage_list_wins(0) == 3 and 1 or 0'
keys Space s m
wait_lexpr "keymap <leader>sm maximizes the current split" 'vim.api.nvim_win_get_height(0) > 40 and 1 or 0'
keys Space s m
wait_lexpr "keymap <leader>sm restores the layout" 'vim.api.nvim_win_get_height(0) < 40 and 1 or 0'
keys Escape ":only" Enter
wait_lexpr "layout back to a single window" '#vim.api.nvim_tabpage_list_wins(0) == 1 and 1 or 0'

# ---------------------------------------------------------------- tabs
keys Space t o
wait_lexpr "keymap <leader>to opens a tab" 'vim.fn.tabpagenr("$") == 2 and 1 or 0'
keys Space t p
wait_lexpr "keymap <leader>tp goes to the previous tab" 'vim.fn.tabpagenr() == 1 and 1 or 0'
keys Space t n
wait_lexpr "keymap <leader>tn goes to the next tab" 'vim.fn.tabpagenr() == 2 and 1 or 0'
keys Escape ":tabclose" Enter
wait_lexpr "back to one tab" 'vim.fn.tabpagenr("$") == 1 and 1 or 0'

# ---------------------------------------------------------------- explorer
keys Space e e
wait_lexpr "keymap <leader>ee opens nvim-tree" "$(win_with_ft NvimTree)"
keys Space e e
wait_lexpr "keymap <leader>ee closes nvim-tree" "(function() return $(win_with_ft NvimTree) == 1 and 0 or 1 end)()"
keys Space e f
wait_lexpr "keymap <leader>ef reveals the file in the tree" "$(win_with_ft NvimTree)"
wait_screen "the revealed file is on screen" "services.py"
keys Space e e

# ---------------------------------------------------------------- buffers
keys Escape ":silent! %bd!" Enter
open_file backend/core/services.py
open_file notes.md
keys Space b p
wait_lexpr "keymap <leader>bp leaves the current buffer" 'vim.fn.expand("%:t") ~= "notes.md" and 1 or 0'
keys Space b n
wait_lexpr "keymap <leader>bn goes to the next buffer" 'vim.fn.expand("%:t") == "notes.md" and 1 or 0'
keys Space b d
wait_lexpr "keymap <leader>bd closes the buffer" 'vim.fn.expand("%:t") ~= "notes.md" and 1 or 0'

# ---------------------------------------------------------------- save
open_file backend/core/services.py
keys G o "# touched by the deep suite" Escape
wait_lexpr "buffer is modified after typing" 'vim.bo.modified and 1 or 0'
keys Space w w
wait_lexpr "keymap <leader>ww saves the buffer" 'vim.bo.modified == false and 1 or 0'
keys u
keys Space w w

# ---------------------------------------------------------------- quit keymaps
open_file notes.md
keys Space t o
open_file backend/demo.py
keys G o "trailing" Escape
keys Space w q
wait_lexpr "keymap <leader>wq saves and closes the window" 'vim.fn.tabpagenr("$") == 1 and 1 or 0' 15
open_file backend/demo.py
keys u
keys Escape ":w" Enter
keys Space t o
keys G o "unsaved" Escape
keys Space q q
wait_lexpr "keymap <leader>qq quits without saving" 'vim.fn.tabpagenr("$") == 1 and 1 or 0' 15

deep_finish
