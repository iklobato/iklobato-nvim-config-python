#!/usr/bin/env bash
# Deep e2e, tools: git, markdown preview, http client and database UI.
# Run alone: ./tests/deep/tools.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup tools
deep_boot backend/core/services.py

# ---------------------------------------------------------------- git and tools
keys Space g b
wait_lexpr "keymap <leader>gb toggles inline git blame" \
  'vim.g.gitblame_enabled == false and 1 or 0' 10
keys Space g b
wait_lexpr "keymap <leader>gb toggles it back on" \
  'vim.g.gitblame_enabled == true and 1 or 0' 10
open_file notes.md
wait_lexpr "gitsigns sees the second commit's hunk context" \
  'vim.b[vim.fn.bufnr("notes.md")].gitsigns_status_dict ~= nil and 1 or 0' 20
wait_lexpr "keymap <leader>mp is bound to MarkdownPreview" \
  'vim.fn.maparg(" mp", "n"):match("MarkdownPreview") ~= nil and 1 or 0' 10
wait_lexpr "keymap <leader>mP is bound to MarkdownPreviewStop" \
  'vim.fn.maparg(" mP", "n"):match("MarkdownPreviewStop") ~= nil and 1 or 0' 10
# a real server, so the request has something to answer it
(cd "$MONO/backend" && "$VIRTUAL_ENV/bin/python" manage.py runserver 8000 --noreload >/dev/null 2>&1) &
for _ in $(seq 1 30); do
  curl -s -m 1 http://127.0.0.1:8000/api/totals/ | grep -q '"total"' && break
  sleep 1
done
open_file api.http
keys Space r r
wait_screen "keymap <leader>rr runs the request and shows the response" "total" 30
# let kulala finish writing its response buffer: pulling the server out from
# under it raises a connection error and a hit-enter prompt
sleep 3
# the debugger starts its own server on 8000 later, so the port has to be free
stop_django
keys Space d b
wait_lexpr "keymap <leader>db opens the database UI" "$(win_with_ft dbui)" 15
# the drawer window exists before dadbod-ui has finished filling it, and a
# toggle sent into that gap is dropped
sleep 3
keys Escape
keys Space d b
wait_lexpr "keymap <leader>db closes the database UI" \
  "(function() return $(win_with_ft dbui) == 1 and 0 or 1 end)()" 25

deep_finish
