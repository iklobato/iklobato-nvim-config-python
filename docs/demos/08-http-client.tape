# HTTP client: run the request under the cursor against the demo Django API.
Output docs/demos/08-http-client.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate" Enter
Type@1ms "(python manage.py runserver 8000 --noreload >/dev/null 2>&1 &)" Enter
Type@1ms "until curl -s -m 1 http://127.0.0.1:8000/api/totals/ >/dev/null; do sleep 1; done; cd /tmp/demo && clear" Enter
Wait@40s
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' api.http` Enter
Sleep 5s
Type@1ms `:lua Cap("api.http","a request to the local Django API (manage.py runserver)")` Enter
Show
Sleep 3s

Hide
Type@1ms `:lua Cap("<leader>rr","run the request under the cursor")` Enter
Show
Sleep 1.5s
Type " rr"
Wait+Screen@30s /"total": 120/
Sleep 5s

Hide
Type@1ms ":qa!" Enter
Sleep 2s
Type@1ms `pkill -f "manage.py runserver 8000"` Enter
Sleep 1s
