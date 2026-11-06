#!/usr/bin/env bash
# Deep e2e, search: telescope file, grep and buffer pickers.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup search
deep_boot backend/core/services.py

# queries skip the "." so only the result list, not the prompt echo, can match
keys Space f f
wait_lexpr "keymap <leader>ff opens the file picker" "$(win_with_ft TelescopePrompt)"
keys "datadb"
wait_screen "ff lists gitignored files (no_ignore)" "data\.db" 20
keys Escape Escape
keys Space f f
wait_lexpr "file picker open again" "$(win_with_ft TelescopePrompt)"
keys "builderpy"
wait_screen "ff keeps builder.py: the build pattern is anchored to a path segment" "builder\.py" 20
keys Escape Escape
keys Space f f
wait_lexpr "file picker open for a pick" "$(win_with_ft TelescopePrompt)"
keys "coreviews"
wait_screen "ff finds backend/core/views.py" "views\.py" 20
keys Enter
wait_lexpr "picking the result opens the file" 'vim.fn.expand("%:t") == "views.py" and 1 or 0' 15

keys Space f g
wait_lexpr "keymap <leader>fg opens live grep" "$(win_with_ft TelescopePrompt)"
keys "def double"
wait_screen "live grep finds the line in another file" "services\.py:" 20
keys Enter
wait_lexpr "picking a grep match opens the file on that line" \
  'vim.fn.expand("%:t") == "services.py" and vim.fn.getline(".") == "def double(value):" and 1 or 0' 15

open_file notes.md
open_file backend/core/services.py
keys Space f b
wait_lexpr "keymap <leader>fb opens the buffer picker" "$(win_with_ft TelescopePrompt)"
keys "notes"
# bufferline also shows notes.md, so check the picker's selection, not the screen
wait_lexpr "fb filters to the typed buffer" \
  '(function() local entry = require("telescope.actions.state").get_selected_entry() return (entry and tostring(entry.filename or entry.value):match("notes%.md$")) and 1 or 0 end)()' 15
keys Enter
wait_lexpr "picking a buffer switches to it" 'vim.fn.expand("%:t") == "notes.md" and 1 or 0' 15

# the fzf extension swaps telescope's own lua sorters for its C ones
wait_lexpr "telescope sorts with fzf-native" \
  'debug.getinfo(require("telescope.config").values.generic_sorter, "S").source:match("fzf") and 1 or 0' 10

open_file backend/core/tasks.py
goto_line 2
keys "]" t
wait_lexpr "keymap ]t jumps to the next TODO comment" 'vim.fn.line(".") == 6 and 1 or 0' 10
keys "[" t
wait_lexpr "keymap [t jumps back to the previous TODO comment" 'vim.fn.line(".") == 1 and 1 or 0' 10
keys Space f t
wait_lexpr "keymap <leader>ft opens the TODO picker" "$(win_with_ft TelescopePrompt)" 15
keys "cache the"
wait_lexpr "ft lists the FIXME in tasks.py" \
  '(function() local entry = require("telescope.actions.state").get_selected_entry() return (entry and tostring(entry.filename or ""):match("tasks%.py$") and entry.lnum == 6) and 1 or 0 end)()' 20
keys Escape Escape

open_file backend/core/legacy.py
wait_lexpr "ruff reports legacy.py's unused imports" '#vim.diagnostic.get(0) >= 2 and 1 or 0' 60
open_file backend/core/services.py
keys Space f d
wait_lexpr "keymap <leader>fd opens the project diagnostics picker" "$(win_with_ft TelescopePrompt)" 15
keys "legacy"
# opened from services.py, so a legacy.py entry proves the list spans the project
wait_lexpr "fd lists diagnostics of another file" \
  '(function() local entry = require("telescope.actions.state").get_selected_entry() return (entry and tostring(entry.filename or ""):match("legacy%.py$")) and 1 or 0 end)()' 20
keys Escape Escape

deep_finish
