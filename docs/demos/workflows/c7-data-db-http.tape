# Chapter 7: data. Fire the HTTP request at the running API, then browse the
# database and run a query. Keys live. Hidden setup starts Django in the bg.
Output docs/demos/workflows/c7-data-db-http.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate" Enter
Type@1ms "(python manage.py runserver 8000 --noreload >/dev/null 2>&1 &)" Enter
Type@1ms "until curl -s -m 1 http://127.0.0.1:8000/api/totals/ >/dev/null; do sleep 1; done; cd /tmp/demo && export DBUI_URL=sqlite:/tmp/demo/data.db DBUI_NAME=demo && clear" Enter
Wait@40s
Type@1ms `nvim --cmd "let g:db_ui_save_location='/tmp/demo/.dbui'" -c 'luafile /tmp/.keycast-demo.lua' api.http` Enter
Wait+Screen@20s /totals/
Sleep 3s
Show
Sleep 1.5s

# fire the request at the running API
Type " rr"
Wait+Screen@30s /"total": 120/
Sleep 5.2s

# the database
Type " db"
Sleep 4.5s
Type "G"
Sleep 450ms
Enter
Wait+Screen@15s /Tables/
Sleep 750ms
Type "/Tables"
Enter
Sleep 450ms
Enter
Wait+Screen@15s /totals/
Sleep 1.5s
Type "j"
Enter
Wait+Screen@15s /List/
Sleep 2.2s
Type "j"
Enter
Sleep 3.8s

# a query
Hide
Type@1ms ":lua for _,w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype=='sql' then vim.api.nvim_set_current_win(w) break end end" Enter
Type@1ms "ggdG"
Type@1ms "i"
Show
Type@150ms "select label, value from totals where value > 30;"
Escape
Sleep 1200ms
Type " S"
Sleep 6s

Hide
Type@1ms ":qa!" Enter
Sleep 3s
Type@1ms `pkill -f "manage.py runserver 8000" ; true` Enter
Sleep 1.5s
