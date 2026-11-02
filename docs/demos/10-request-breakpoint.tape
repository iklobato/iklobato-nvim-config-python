# Workflow: an HTTP request to the Django API stops on a breakpoint in the view.
Output docs/demos/10-request-breakpoint.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/views.py ../api.http` Enter
Sleep 6s
Type@1ms ":14"
Enter
Type@1ms "^"
Type@1ms `:lua Cap("views.py","the API view behind GET /api/totals/")` Enter
Show
Sleep 2.5s

Hide
Type@1ms `:lua Cap("<leader>bb","breakpoint in the view")` Enter
Show
Sleep 1.5s
Type " bb"
Sleep 1.5s

Hide
Type@1ms `:lua Cap("<leader>dc","start the Django server under the debugger")` Enter
Show
Sleep 1.5s
Type " dc"
Wait+Screen@20s /Django runserver/
Sleep 1.5s
Type "2"
Enter
Wait+Screen@60s /Quit the server/
Sleep 2s

Hide
Type@1ms `:lua Cap("<leader>tn","to api.http, the request file")` Enter
Show
Sleep 1s
Type " tn"
Sleep 1.5s
Hide
Type@1ms "gg"
Type@1ms `:lua Cap("<leader>rr","send the request: it stops in the view")` Enter
Show
Sleep 1.5s
Type " rr"
Wait+Screen@30s /Locals:/
Sleep 4s

Hide
Type@1ms `:lua Cap("<leader>dc","continue: the response comes back")` Enter
Show
Sleep 1s
Type " dc"
Wait+Screen@30s /"total": 120/
Sleep 4s

Hide
Type@1ms ":lua require('dap').terminate()" Enter
Sleep 2s
Type@1ms ":qa!" Enter
Sleep 2s
Type@1ms `pkill -f "manage.py runserver" ; true` Enter
Sleep 1s
