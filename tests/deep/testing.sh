#!/usr/bin/env bash
# Deep e2e, testing: neotest runs, debugs and reports the backend's pytest suite.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup testing
deep_boot backend/tests/test_services.py

counts() {
  echo '(function() local s = require("neotest").state local id = s.adapter_ids()[1] local c = id and s.status_counts(id, { buffer = vim.api.nvim_get_current_buf() }) return (c and c.passed == '"$1"' and c.failed == 0) and 1 or 0 end)()'
}

goto_line 5
keys Space n n
wait_lexpr "keymap <leader>nn runs only the nearest test, and it passes" "$(counts 1)" 90
keys Space n f
wait_lexpr "keymap <leader>nf runs every test in the file" "$(counts 3)" 90

keys Space n o
wait_lexpr "keymap <leader>no opens the test output float" 'vim.api.nvim_win_get_config(0).relative ~= "" and 1 or 0' 15
lexpr '(function() vim.api.nvim_win_close(0, true) return 1 end)()' >/dev/null

keys Space n s
wait_lexpr "keymap <leader>ns opens the test summary" "$(win_with_ft neotest-summary)" 15
keys Space n s
wait_lexpr "<leader>ns again closes it" "(function() return $(win_with_ft neotest-summary) == 1 and 0 or 1 end)()" 15

open_file backend/tests/test_services.py
goto_line 17
keys Space b b
wait_lexpr "breakpoint inside test_double_negative" "$(bp_count) == 1 and 1 or 0" 10
keys Space n d
wait_lexpr "keymap <leader>nd debugs the nearest test and stops on its breakpoint" \
  "($(session_stopped) == 1 and $(frame_line 17) == 1) and 1 or 0" 90
keys Space d c
wait_lexpr "the nd debug run finishes" "$(no_session)" 60
keys Space b r

deep_finish
