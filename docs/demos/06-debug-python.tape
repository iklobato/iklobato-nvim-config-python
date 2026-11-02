# Python debug run: conditional breakpoint, logpoint, stepping, dap-ui.
Output docs/demos/06-debug-python.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/services.py` Enter
Sleep 6s
Type@1ms ":9"
Enter
Type@1ms "^"
Show

Hide
Type@1ms `:lua Cap("<leader>bc","breakpoint that stops only when number == 3")` Enter
Show
Sleep 1.5s
Type " bc"
Sleep 1s
Type@100ms "number == 3"
Sleep 800ms
Enter
Sleep 1.5s

Hide
Type@1ms ":3"
Enter
Type@1ms "^"
Type@1ms `:lua Cap("<leader>bl","logpoint: print, do not stop")` Enter
Show
Sleep 1.5s
Type " bl"
Sleep 1s
Type@100ms "dbl {doubled}"
Sleep 800ms
Enter
Sleep 1.5s

Hide
Type@1ms ":edit demo.py" Enter
Type@1ms `:lua Cap("<leader>dc","start: pick a config")` Enter
Show
Sleep 1.5s
Type " dc"
Wait+Screen@20s /Django runserver/
Sleep 2s
Type "1"
Enter
Wait+Screen@60s /Locals:/
Sleep 4s

Hide
Type@1ms `:lua Cap("<leader>dk","step into double()")` Enter
Show
Sleep 1s
Type " dk"
Sleep 3s
Hide
Type@1ms `:lua Cap("<leader>do","step out, back to the loop")` Enter
Show
Sleep 1s
Type " do"
Sleep 3s
Hide
Type@1ms `:lua Cap("<leader>dj","step over one line")` Enter
Show
Sleep 1s
Type " dj"
Sleep 3s

Hide
Type@1ms `:lua Cap("<leader>dc","continue to the end: logpoint lines are in the REPL")` Enter
Show
Sleep 1s
Type " dc"
Sleep 5s
