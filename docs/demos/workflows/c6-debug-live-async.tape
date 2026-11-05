# Chapter 6: debug live. An HTTP request stops on a breakpoint in the Django view,
# then an error lost in an asyncio task stops the debugger. Keys live.
Output docs/demos/workflows/c6-debug-live-async.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' core/views.py ../api.http async_demo.py" Enter
Wait+Screen@30s /def index/
Sleep 3s
Show
Sleep 1.5s

# breakpoint in the view
Type@1ms ":14" Enter
Type "^"
Type " bb"
Sleep 2.2s

# start Django under the debugger
Type " dc"
Wait+Screen@20s /Django runserver/
Sleep 1.5s
Type "2"
Enter
Wait+Screen@60s /Quit the server/
Sleep 2.2s

# send the request: it stops in the view
Type " tn"
Sleep 1.8s
Type "gg"
Type " rr"
Wait+Screen@30s /Locals:/
Sleep 5.2s
Type " dc"
Wait+Screen@30s /"total": 120/
Sleep 4.5s
Type@1ms ":lua require('dap').terminate()" Enter
Sleep 3s

# an error lost in an asyncio task
Type@1ms ":b async_demo.py" Enter
Wait+Screen@15s /create_task/
Sleep 2.2s
Type " be"
Wait+Screen@15s /user unhandled/
Sleep 3s
Type "2"
Enter
Sleep 1.5s
Type " dc"
Wait+Screen@20s /Uvicorn/
Sleep 1.5s
Type "1"
Enter
Wait+Screen@40s /Locals:/
Sleep 5.2s
Type " dc"
Sleep 4.5s

Hide
Type@1ms ":lua require('dap').terminate()" Enter
Sleep 1.5s
Type@1ms ":qa!" Enter
Sleep 1.5s
Type@1ms `pkill -f "manage.py runserver" ; true` Enter
Sleep 1.5s
