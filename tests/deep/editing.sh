#!/usr/bin/env bash
# Deep e2e, editing: treesitter textobjects, highlight and indent rules,
# puppeteer's f-string rewrite, <leader>S substitutions, counted diagnostic
# jumps, and the options a user feels while typing.
# Run alone: ./tests/deep/editing.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup editing
deep_boot backend/core/services.py

lines_are() { # lua list of the exact buffer lines
  echo "vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), $1) and 1 or 0"
}
scratch() { # filetype, lua list of lines: a fresh unnamed buffer to edit freely
  lexpr "(function() vim.cmd(\"enew!\") vim.bo.filetype = \"$1\" vim.api.nvim_buf_set_lines(0, 0, -1, false, $2) vim.api.nvim_win_set_cursor(0, { 1, 0 }) return 1 end)()" >/dev/null
}

# ---------------------------------------------------------------- treesitter
wait_lexpr "treesitter highlights python" 'vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] and 1 or 0' 15
# python indent stays on nvim's own indentexpr, every other language gets the
# treesitter one
wait_lexpr "python keeps nvim's own indentexpr" 'not vim.bo.indentexpr:match("nvim%-treesitter") and 1 or 0'
open_file langs/tool.lua
wait_lexpr "lua gets the treesitter indentexpr" 'vim.bo.indentexpr:match("nvim%-treesitter") and 1 or 0' 15

open_file backend/core/services.py
goto_line 2
keys d i f
wait_lexpr "dif empties the function body and keeps its def line" \
  '(function() local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") return (text:match("def double%(value%):") and not text:match("doubled") and text:match("def summarize")) and 1 or 0 end)()' 10
keys u
goto_line 7
keys d a f
wait_lexpr "daf deletes the whole function" '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match("summarize") then return 0 end end return 1 end)()' 10
keys u
wait_lexpr "undo brings services.py back" 'vim.bo.modified == false and 1 or 0' 10

open_file backend/tests/test_services.py
goto_line 16
keys d i c
wait_lexpr "dic empties the class body" '(function() local l = vim.api.nvim_buf_get_lines(0, 0, -1, false) return (l[#l]:match("^class TestServices") or l[#l - 1]:match("^class TestServices")) and 1 or 0 end)()' 10
keys u
goto_line 16
keys d a c
wait_lexpr "dac deletes the whole class" '(function() for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match("TestServices") then return 0 end end return 1 end)()' 10
keys u
wait_lexpr "undo brings the test file back" 'vim.bo.modified == false and 1 or 0' 10

# files over 1 MB skip treesitter, so a huge generated file stays fast
# toml: a parser is installed and no language server would chew on 1 MB
big="$MONO/langs/big_generated.toml"
python3 -c 'import sys; open(sys.argv[1], "w").write("".join(f"key{i} = {i}\n" for i in range(80000)))' "$big"
open_file langs/big_generated.toml
sleep 1
wait_lexpr "a file over 1 MB is left without treesitter" 'vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] == nil and 1 or 0' 10
keys Escape ":bd!" Enter
rm -f "$big"

# ---------------------------------------------------------------- puppeteer
# a python string that gains a {} becomes an f-string on InsertLeave, and the
# same edit in typescript is left alone (puppeteer_disabled_filetypes)
open_file backend/demo.py
keys G o 'label = "total {numbers}"' Escape
wait_lexpr "puppeteer turns a python string with {} into an f-string" 'vim.fn.getline("$") == "label = f\"total {numbers}\"" and 1 or 0' 10
keys Escape ":e!" Enter
open_file frontend/src/lib/shape.ts
# no trailing ";": tmux send-keys reads an argument ending in ";" as its own
# command separator
keys G o 'const label = "total ${numbers}"' Escape
wait_lexpr "typed the typescript line" 'vim.fn.getline("$"):match("^const label") and vim.fn.mode() == "n" and 1 or 0' 10
sleep 1
# in js/ts puppeteer reacts to ${}, turning the quotes into backticks
wait_lexpr "puppeteer leaves typescript strings alone" 'vim.fn.getline("$") == "const label = \"total ${numbers}\"" and 1 or 0' 10
keys Escape ":e!" Enter

# ---------------------------------------------------------------- substitute
scratch text '{ "alpha beta alpha", "Alpha alpha" }'
keys Space S
wait_screen "keymap <leader>S prefills the substitute command" ":%s/" 10
keys C-w "omega" Enter
# the I flag keeps the match case-sensitive despite ignorecase
wait_lexpr "<leader>S replaces every match of the word, case-sensitively" "$(lines_are '{ "omega beta omega", "Alpha omega" }')" 10
scratch text '{ "one two", "two one two" }'
keys "0" "w" "v" "e"
keys Space S
wait_screen "visual <leader>S prefills from the selection" ":%s/two/" 10
keys C-w "three" Enter
wait_lexpr "visual <leader>S replaces the selected text everywhere" "$(lines_are '{ "one three", "three one three" }')" 10

# ---------------------------------------------------------------- counted jumps
open_file backend/core/legacy.py
wait_lexpr "ruff reports the two unused imports" '#vim.diagnostic.get(0) >= 2 and 1 or 0' 60
goto_line 9
keys 2 "[" d
# nvim's own [d also takes a count; the float is what shows it was the config's
wait_lexpr "2[d jumps two diagnostics back, not one, and shows it" \
  '(function() local float = false for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= "" then float = true end end return (vim.fn.line(".") == 1 and float) and 1 or 0 end)()' 10

# ---------------------------------------------------------------- options
open_file backend/core/services.py
keys Escape ":vsplit" Enter
wait_lexpr "splitright: a vertical split opens on the right" 'vim.fn.winnr() == 2 and 1 or 0' 10
keys Escape ":only" Enter
# counted without moving, so a pattern with no match leaves no E486 behind
wait_lexpr "ignorecase: a lowercase search matches any case" \
  'vim.fn.searchcount({ pattern = "def double", recompute = true }).total > 0 and vim.fn.searchcount({ pattern = "DEF DOUBLE", recompute = true }).total == 0 and 1 or 0' 10
wait_lexpr "mouse is off" 'vim.o.mouse == "" and 1 or 0'
wait_lexpr "no swapfile is written" 'vim.bo.swapfile == false and 1 or 0'

deep_finish
