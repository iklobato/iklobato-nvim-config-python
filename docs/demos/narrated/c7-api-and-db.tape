# Narrated chapter 7: check an API and its data without leaving the editor. Send
# the request from a .http file, open the database, browse a table, run a query.
# The hidden setup starts Django in the background and the hidden end stops it.
# Same sync rules as c5-debug-python.tape: Framerate 15, every Wait inside Hide,
# hidden moves end with a 2.2 s pause.
# Each "# step N" matches sentence N of c7-api-and-db.json. The Sleep that ends
# each step is sized from the measured spoken length of its line + 0.9 s.
Output "docs/demos/narrated/c7-api-and-db.silent.mp4"
Source docs/demos/settings.tape
Set Framerate 15

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

# step 0: intro
Sleep 9.2s

# step 1: send the request
Type " rr"
Hide
Wait+Screen@30s /"total": 120/
Show
Sleep 6.9s

# step 2: open the database
Type " db"
Hide
Sleep 1.5s
Show
Sleep 3.3s

# step 3: browse to the table rows
Type "G"
Sleep 0.5s
Enter
Hide
Wait+Screen@15s /Tables/
Show
Sleep 0.8s
Type "/Tables"
Enter
Sleep 0.5s
Enter
Hide
Wait+Screen@15s /totals/
Show
Sleep 0.8s
Type "j"
Enter
Hide
Wait+Screen@15s /List/
Show
Sleep 0.8s
Type "j"
Enter
Sleep 2s

# step 4: run a query
Hide
Type@1ms ":lua for _,w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype=='sql' then vim.api.nvim_set_current_win(w) break end end" Enter
Type@1ms "ggdG"
Type@1ms "i"
Sleep 2.2s
Show
Type@150ms "select label, value from totals where value > 30;"
Escape
Sleep 1s
Type " S"
Sleep 2s

# step 5: outro
Sleep 7.4s

Hide
Type@1ms ":qa!" Enter
Sleep 3s
Type@1ms `pkill -f "manage.py runserver 8000" ; true` Enter
Sleep 1.5s
