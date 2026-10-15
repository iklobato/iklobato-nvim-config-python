#!/usr/bin/env bash
# Deep e2e, tools: git, markdown preview, http client and database UI.
# Run alone: ./tests/deep/tools.sh   (./tests/e2e-deep.sh runs every area)
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup tools
deep_boot backend/core/services.py

# ---------------------------------------------------------------- git blame
BLAME_MARKS='#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("git-blame-virtual-text"), 0, -1, {})'
goto_line 2
wait_lexpr "git-blame draws the inline blame text" "$BLAME_MARKS > 0 and 1 or 0" 15
keys Space g b
blame_turned_off=""
wait_lexpr "keymap <leader>gb turns inline git blame off" \
  "(vim.g.gitblame_enabled == false and $BLAME_MARKS == 0) and 1 or 0" 10 && blame_turned_off=1
keys Space g b
goto_line 3
# "back on" only means something after it went off; with the map gone it never
# leaves the on state and the check below would pass on its own
if [ -n "$blame_turned_off" ]; then
  wait_lexpr "keymap <leader>gb turns it back on and the text returns" \
    "(vim.g.gitblame_enabled == true and $BLAME_MARKS > 0) and 1 or 0" 15
else
  bad "keymap <leader>gb turns it back on and the text returns" "blame never turned off"
fi

# ---------------------------------------------------------------- gitsigns
open_file notes.md
wait_lexpr "gitsigns attaches to a tracked file" \
  'vim.b[vim.fn.bufnr("notes.md")].gitsigns_status_dict ~= nil and 1 or 0' 20
keys G o "edited by the deep suite" Escape
wait_lexpr "gitsigns turns an edit into a hunk" '#(require("gitsigns").get_hunks(0) or {}) > 0 and 1 or 0' 15
keys Escape ":e!" Enter

# ---------------------------------------------------------------- markdown preview
# record the URL instead of opening a browser; the server itself is real
lexpr '(function() vim.cmd("function! E2eRecordPreviewUrl(url)\n let g:e2e_preview_url = a:url\nendfunction") vim.g.mkdp_browserfunc = "E2eRecordPreviewUrl" return 1 end)()' >/dev/null
keys Space m p
wait_lexpr "keymap <leader>mp starts the preview server" 'vim.g.e2e_preview_url ~= nil and 1 or 0' 30
preview_url=$(expr_ 'get(g:, "e2e_preview_url", "")')
preview_status=""
for _ in $(seq 1 20); do
  preview_status=$(curl -s -m 2 -o /dev/null -w '%{http_code}' "$preview_url")
  [ "$preview_status" = "200" ] && break
  sleep 0.5
done
if [ "$preview_status" = "200" ]; then
  ok "the preview page answers 200"
else
  bad "the preview page answers 200" "url=$preview_url status=$preview_status"
fi
keys Space m P
preview_down=""
for _ in $(seq 1 20); do
  curl -s -m 1 -o /dev/null "$preview_url" || {
    preview_down=1
    break
  }
  sleep 0.5
done
# with no url (the server never started) curl fails at once, which is not proof
# that <leader>mP stopped anything
if [ "$preview_status" = "200" ] && [ -n "$preview_down" ]; then
  ok "keymap <leader>mP stops the preview server"
else
  bad "keymap <leader>mP stops the preview server" "url=$preview_url served=$preview_status down=${preview_down:-no}"
fi

# ---------------------------------------------------------------- http and database
# a real server, so the request has something to answer it
(cd "$MONO/backend" && "$VIRTUAL_ENV/bin/python" manage.py runserver 8000 --noreload >/dev/null 2>&1) &
for _ in $(seq 1 30); do
  curl -s -m 1 http://127.0.0.1:8000/api/totals/ | grep -q '"total"' && break
  sleep 1
done
open_file api.http
keys Space r r
# "total" is also in the request's URL, and kulala folds the JSON body, so read
# the status line its response pane prints for a request that came back
wait_screen "keymap <leader>rr runs the request and shows the response" "Status: 200" 30
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
