#!/usr/bin/env bash
# Deep e2e, tools: git, markdown preview, http client and database UI.
set -uo pipefail

TESTS="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/tmux_lib.sh
source "$TESTS/tmux_lib.sh"

deep_setup tools
deep_boot backend/core/services.py

BLAME_MARKS='#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("git-blame-virtual-text"), 0, -1, {})'
goto_line 2
wait_lexpr "git-blame draws the inline blame text" "$BLAME_MARKS > 0 and 1 or 0" 15
keys Space g b
blame_turned_off=""
wait_lexpr "keymap <leader>gb turns inline git blame off" \
  "(vim.g.gitblame_enabled == false and $BLAME_MARKS == 0) and 1 or 0" 10 && blame_turned_off=1
keys Space g b
goto_line 3
# "back on" only means something after it went off, else it passes on its own
if [ -n "$blame_turned_off" ]; then
  wait_lexpr "keymap <leader>gb turns it back on and the text returns" \
    "(vim.g.gitblame_enabled == true and $BLAME_MARKS > 0) and 1 or 0" 15
else
  bad "keymap <leader>gb turns it back on and the text returns" "blame never turned off"
fi

open_file notes.md
wait_lexpr "gitsigns attaches to a tracked file" \
  'vim.b[vim.fn.bufnr("notes.md")].gitsigns_status_dict ~= nil and 1 or 0' 20
keys G o "edited by the deep suite" Escape
wait_lexpr "gitsigns turns an edit into a hunk" '#(require("gitsigns").get_hunks(0) or {}) > 0 and 1 or 0' 15
keys Escape ":e!" Enter

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
# needs the 200 first: with no server curl fails at once and proves nothing
if [ "$preview_status" = "200" ] && [ -n "$preview_down" ]; then
  ok "keymap <leader>mP stops the preview server"
else
  bad "keymap <leader>mP stops the preview server" "url=$preview_url served=$preview_status down=${preview_down:-no}"
fi

(cd "$MONO/backend" && "$VIRTUAL_ENV/bin/python" manage.py runserver 8000 --noreload >/dev/null 2>&1) &
for _ in $(seq 1 30); do
  curl -s -m 1 http://127.0.0.1:8000/api/totals/ | grep -q '"total"' && break
  sleep 1
done
open_file api.http
keys Space r r
# not "total": it is in the request URL too, and kulala folds the JSON body
wait_screen "keymap <leader>rr runs the request and shows the response" "Status: 200" 30
# stopping the server before kulala finishes raises a hit-enter prompt
sleep 3
stop_django
keys Space d b
wait_lexpr "keymap <leader>db opens the database UI" "$(win_with_ft dbui)" 15
# a toggle sent before dadbod-ui fills its drawer is dropped
sleep 3
keys Escape
keys Space d b
wait_lexpr "keymap <leader>db closes the database UI" \
  "(function() return $(win_with_ft dbui) == 1 and 0 or 1 end)()" 25

DBOUT_WIN='(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match("%.dbout$") then return w end end end)()'
open_file notes.md
keys Escape ":DB sqlite:data.db select label, value from totals order by id" Enter
wait_lexpr "a dadbod query shows its rows in a .dbout window" \
  "(function() local w = $DBOUT_WIN if not w then return 0 end local text = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(w), 0, -1, false), \" \") return (text:match(\"second\") and text:match(\"40\")) and 1 or 0 end)()" 20
wait_lexpr "the result window takes 75% of the screen" \
  "(function() local w = $DBOUT_WIN return (w and vim.api.nvim_win_get_height(w) >= math.floor((vim.o.lines - 2) * 0.75) - 1) and 1 or 0 end)()" 10
keys Escape ":silent! only" Enter

# dadbod completions need a sql buffer with vim.b.db set
lexpr '(function() vim.cmd("enew!") vim.bo.filetype = "sql" vim.b.db = "sqlite:data.db" return 1 end)()' >/dev/null
keys i "select * from tot"
wait_lexpr "sql completion offers the table from the database" \
  '(function() for _, item in ipairs(require("blink.cmp.completion.list").items or {}) do if item.label == "totals" and item.source_id == "dadbod" then return 1 end end return 0 end)()' 30
keys Escape

deep_finish
