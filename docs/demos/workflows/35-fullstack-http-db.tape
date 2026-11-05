# Workflow V6: a full-stack check. Fire the HTTP request at the running API, read
# the JSON, then open the database and browse the table: both sides of the stack
# in one session. The hidden setup starts Django in the background and waits for it.
Output docs/demos/workflows/35-fullstack-http-db.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate" Enter
Type@1ms "(python manage.py runserver 8000 --noreload >/dev/null 2>&1 &)" Enter
Type@1ms "until curl -s -m 1 http://127.0.0.1:8000/api/totals/ >/dev/null; do sleep 1; done; cd /tmp/demo && export DBUI_URL=sqlite:/tmp/demo/data.db DBUI_NAME=demo && clear" Enter
Wait@40s
Type@1ms `nvim --cmd "let g:db_ui_save_location='/tmp/demo/.dbui'" -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' api.http` Enter
Wait+Screen@20s /totals/
Sleep 2s
Show
Sleep 1s

# fire the request at the running API
Hide
Type@1ms `:lua Cap("<leader>rr","send the request to the running API")` Enter
Show
Sleep 1.2s
Type " rr"
Wait+Screen@30s /"total": 120/
Sleep 4s

# now the other side: the database
Hide
Type@1ms `:lua Cap("<leader>db","now the other side: the database")` Enter
Show
Sleep 1.2s
Type " db"
Sleep 3s
Type "G"
Sleep 300ms
Enter
Wait+Screen@15s /Tables/
Sleep 500ms
Type "/Tables"
Enter
Sleep 300ms
Enter
Wait+Screen@15s /totals/
Sleep 1.2s
Type "j"
Enter
Sleep 4s

Hide
Type@1ms ":qa!" Enter
Sleep 2s
Type@1ms `pkill -f "manage.py runserver 8000" ; true` Enter
Sleep 1s
