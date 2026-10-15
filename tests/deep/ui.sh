#!/usr/bin/env bash
# Deep e2e, ui: bufferline, motions, windows, tabs, explorer, buffers, save and quit.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup ui
deep_boot backend/core/services.py

# lualine also prints the filename, so read the tabline, not the screen
wait_lexpr "bufferline draws the open file as a tab" \
  '(vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true }).str:find("services.py", 1, true) and 1 or 0)' 15

# the "not same(want, other)" half stops the check passing with the map deleted
remember_cursor() {
  lexpr '(function() _G.__pre = vim.api.nvim_win_get_cursor(0) return 1 end)()' >/dev/null
}
lands_like() { # builtin it stands for, builtin it replaces
  echo '(function() local got = vim.api.nvim_win_get_cursor(0) local function at(k) vim.api.nvim_win_set_cursor(0, _G.__pre) vim.cmd("normal! " .. k) return vim.api.nvim_win_get_cursor(0) end local want, other = at("'"$1"'"), at("'"$2"'") vim.api.nvim_win_set_cursor(0, got) local function same(a, b) return a[1] == b[1] and a[2] == b[2] end return (same(got, want) and not same(want, other)) and 1 or 0 end)()'
}

goto_line 2
keys L
wait_lexpr "keymap L jumps to end of line" 'vim.fn.col(".") >= 22 and 1 or 0'
keys H
wait_lexpr "keymap H jumps to first non-blank" 'vim.fn.col(".") == 5 and 1 or 0'
goto_line 9
keys "0"
wait_lexpr "cursor at the start of line 9" 'vim.fn.line(".") == 9 and vim.fn.col(".") == 1 and 1 or 0'
remember_cursor
keys B
wait_lexpr "keymap B moves a WORD forward, like builtin W" "$(lands_like W B)"
keys Escape '$'
wait_lexpr "cursor at the end of line 9" 'vim.fn.col(".") == vim.fn.col("$") - 1 and 1 or 0'
remember_cursor
keys W
wait_lexpr "keymap W moves a WORD back, like builtin B" "$(lands_like B W)"
# gj and j only differ on a wrapped line, and "second" is where a plain j lands
lexpr '(function() vim.cmd("enew") vim.wo.wrap = true vim.api.nvim_buf_set_lines(0, 0, -1, false, { string.rep("word ", 100), "second" }) vim.api.nvim_win_set_cursor(0, { 1, 0 }) return 1 end)()' >/dev/null
keys Space j
wait_lexpr "keymap <leader>j moves down a screen line inside a wrapped line" \
  'vim.fn.line(".") == 1 and vim.fn.col(".") > 100 and 1 or 0'
# on line 1 a plain k cannot move, so only gk moves the column back
lexpr '(function() vim.api.nvim_win_set_cursor(0, { 1, 300 }) return 1 end)()' >/dev/null
keys Space k
wait_lexpr "keymap <leader>k moves up a screen line inside a wrapped line" \
  'vim.fn.line(".") == 1 and vim.fn.col(".") < 200 and 1 or 0'
keys Escape ":bd!" Enter
wait_lexpr "back on services.py" 'vim.fn.expand("%:t") == "services.py" and 1 or 0'

keys Space s v
wait_lexpr "keymap <leader>sv splits vertically" '#vim.api.nvim_tabpage_list_wins(0) == 2 and 1 or 0'
keys Space s h
wait_lexpr "keymap <leader>sh splits horizontally" '#vim.api.nvim_tabpage_list_wins(0) == 3 and 1 or 0'
# uneven splits in a second tab too: <leader>se must even out every tab
lexpr '(function() vim.cmd("vertical resize 40") local cur = vim.api.nvim_get_current_tabpage() vim.cmd("tabnew") vim.cmd("vsplit") vim.cmd("vertical resize 30") vim.api.nvim_set_current_tabpage(cur) return 1 end)()' >/dev/null
keys Space s e
wait_lexpr "keymap <leader>se evens out the splits of every tab" \
  '(function() local function first(n) while n[1] ~= "leaf" do n = n[2][1] end return n[2] end local function even(n) if n[1] == "leaf" then return true end local size = n[1] == "row" and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height local lo, hi = math.huge, 0 for _, c in ipairs(n[2]) do local s = size(first(c)) lo, hi = math.min(lo, s), math.max(hi, s) if not even(c) then return false end end return hi - lo <= 1 end for _, tab in ipairs(vim.api.nvim_list_tabpages()) do if not even(vim.fn.winlayout(vim.api.nvim_tabpage_get_number(tab))) then return 0 end end return 1 end)()'
wait_lexpr "keymap <leader>se keeps every window" '#vim.api.nvim_tabpage_list_wins(0) == 3 and 1 or 0'
keys Escape ":tabonly" Enter
wait_lexpr "back to one tab" 'vim.fn.tabpagenr("$") == 1 and 1 or 0'
keys Space s m
wait_lexpr "keymap <leader>sm maximizes the current split" 'vim.api.nvim_win_get_height(0) > 40 and 1 or 0'
keys Space s m
wait_lexpr "keymap <leader>sm restores the layout" 'vim.api.nvim_win_get_height(0) < 40 and 1 or 0'
keys Escape ":only" Enter
wait_lexpr "layout back to a single window" '#vim.api.nvim_tabpage_list_wins(0) == 1 and 1 or 0'

keys Space t o
wait_lexpr "keymap <leader>to opens a tab" 'vim.fn.tabpagenr("$") == 2 and 1 or 0'
keys Space t p
wait_lexpr "keymap <leader>tp goes to the previous tab" 'vim.fn.tabpagenr() == 1 and 1 or 0'
keys Space t n
wait_lexpr "keymap <leader>tn goes to the next tab" 'vim.fn.tabpagenr() == 2 and 1 or 0'
keys Escape ":tabclose" Enter
wait_lexpr "back to one tab" 'vim.fn.tabpagenr("$") == 1 and 1 or 0'

keys Space e e
wait_lexpr "keymap <leader>ee opens nvim-tree" "$(win_with_ft NvimTree)"
keys Space e e
wait_lexpr "keymap <leader>ee closes nvim-tree" "(function() return $(win_with_ft NvimTree) == 1 and 0 or 1 end)()"
keys Space e f
wait_lexpr "keymap <leader>ef reveals the file in the tree" "$(win_with_ft NvimTree)"
wait_lexpr "the tree cursor sits on the revealed file" \
  '(function() local ok, api = pcall(require, "nvim-tree.api") local node = ok and api.tree.get_node_under_cursor() return (node and node.name == "services.py") and 1 or 0 end)()'
keys Space e e

keys Escape ":silent! %bd!" Enter
open_file backend/core/services.py
open_file notes.md
keys Space b p
wait_lexpr "keymap <leader>bp leaves the current buffer" 'vim.fn.expand("%:t") ~= "notes.md" and 1 or 0'
keys Space b n
wait_lexpr "keymap <leader>bn goes to the next buffer" 'vim.fn.expand("%:t") == "notes.md" and 1 or 0'
keys Space b d
wait_lexpr "keymap <leader>bd closes the buffer" 'vim.fn.expand("%:t") ~= "notes.md" and 1 or 0'

open_file backend/core/services.py
keys G o "# touched by the deep suite" Escape
wait_lexpr "buffer is modified after typing" 'vim.bo.modified and 1 or 0'
keys Space w w
wait_lexpr "keymap <leader>ww saves the buffer" 'vim.bo.modified == false and 1 or 0'
keys u
keys Space w w

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
