#!/usr/bin/env bash
# Deep e2e, session: auto-session save and restore; explorer only when nothing restored.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup session

# headless on purpose: auto-session does not save a new session on the way out
session_reset() {
  (cd "$MONO" && nvim --headless -c 'lua pcall(require("auto-session").delete_session)' -c 'qa!' >/dev/null 2>&1)
}

quit_nvim() {
  keys Escape ":qa" Enter
  for _ in $(seq 1 20); do
    tmux has-session -t "$S" 2>/dev/null || break
    sleep 0.5
  done
  if tmux has-session -t "$S" 2>/dev/null; then
    bad "$1" "tmux session still alive"
  else
    ok "$1"
  fi
}

LISTED='(function() local names = {} for _, b in ipairs(vim.api.nvim_list_bufs()) do if vim.bo[b].buflisted then names[vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")] = true end end return names end)()'

session_reset

deep_boot ""
wait_lexpr "with no session for the cwd, the explorer opens" "$(win_with_ft NvimTree)" 15
wait_lexpr "and nothing was restored" 'vim.g.auto_session_restored == false and 1 or 0'
open_file backend/core/services.py
open_file notes.md
# left open on purpose: close_filetypes_on_save must keep it out of the session
keys Space e e
wait_lexpr "explorer open when quitting" "$(win_with_ft NvimTree)"
quit_nvim "quitting writes the session"

deep_boot ""
wait_lexpr "the next start restores the session" 'vim.g.auto_session_restored == true and 1 or 0' 20
wait_lexpr "both buffers come back" "(function() local n = $LISTED return (n[\"services.py\"] and n[\"notes.md\"]) and 1 or 0 end)()" 15
# the explorer opens 100ms after VimEnter: without the sleep this passes vacuously
sleep 1
wait_lexpr "no explorer on top of a restored session" "(function() return $(win_with_ft NvimTree) == 1 and 0 or 1 end)()"
wait_lexpr "the session did not save the explorer as a buffer" \
  '(function() for _, b in ipairs(vim.api.nvim_list_bufs()) do if vim.api.nvim_buf_get_name(b):match("NvimTree_") then return 0 end end return 1 end)()'
quit_nvim "quitting the restored session"

deep_boot "."
wait_lexpr "nvim . restores the session too" 'vim.g.auto_session_restored == true and 1 or 0' 20
sleep 1
wait_lexpr "nvim . opens no explorer over the restored buffers" "(function() return $(win_with_ft NvimTree) == 1 and 0 or 1 end)()"

deep_finish
status=$?
session_reset
exit $status
