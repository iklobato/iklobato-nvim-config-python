# Narrated chapter 6: debug a live Django request, then an error lost inside an
# asyncio task. Breakpoint in the view, Django under the debugger, the request
# sent from the editor stops in the view; then stop on unhandled exceptions and
# catch the one a task would swallow.
# Same sync rules as c5-debug-python.tape: Framerate 15, every Wait inside Hide,
# hidden moves end with a 2.2 s pause. The hidden end stops the debugger and any
# Django left running.
# Each "# step N" matches sentence N of c6-debug-django.json. The Sleep that ends
# each step is sized from the measured spoken length of its line + 0.9 s.
Output "docs/demos/narrated/c6-debug-django.silent.mp4"
Source docs/demos/settings.tape
Set Framerate 15

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' core/views.py ../api.http async_demo.py" Enter
Wait+Screen@30s /def index/
Type@1ms ":14" Enter
Type "^"
Sleep 2.2s
Show

# step 0: intro
Sleep 8.4s

# step 1: breakpoint in the view
Type " bb"
Sleep 3.3s

# step 2: Django under the debugger
Type " dc"
Hide
Wait+Screen@20s /Django runserver/
Show
Sleep 1.5s
Type "2"
Enter
Hide
Wait+Screen@60s /Quit the server/
Show
Sleep 5.6s

# step 3: send the request, it stops in the view
Hide
Type " tn"
Type "gg"
Sleep 2.2s
Show
Type " rr"
Hide
Wait+Screen@30s /Locals:/
Show
Sleep 7.3s

# step 4: continue, the response comes back
Type " dc"
Hide
Wait+Screen@30s /"total": 120/
Show
Sleep 4.7s

# step 5: stop on exceptions nobody handles
Hide
Type@1ms ":lua require('dap').terminate()" Enter
Sleep 3s
Type@1ms ":b async_demo.py" Enter
Wait+Screen@15s /create_task/
Sleep 2.2s
Show
Type " be"
Hide
Wait+Screen@15s /user unhandled/
Show
Sleep 1.5s
Type "2"
Enter
Sleep 7.4s

# step 6: run it, it stops where the error was raised
Type " dc"
Hide
Wait+Screen@20s /Uvicorn/
Show
Sleep 1.5s
Type "1"
Enter
Hide
Wait+Screen@40s /Locals:/
Show
Sleep 3.7s

# step 7: outro
Sleep 6.5s

Hide
Type@1ms ":lua require('dap').terminate()" Enter
Sleep 1.5s
Type@1ms ":qa!" Enter
Sleep 1.5s
Type@1ms `pkill -f "manage.py runserver" ; true` Enter
Sleep 1.5s
