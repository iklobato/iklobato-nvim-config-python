# Debug the pytest test under the cursor, or pick one from a list.
Output docs/demos/07-debug-pytest.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' tests/test_services.py` Enter
Sleep 8s
Type@1ms ":11"
Enter
Type@1ms "^"
Show

Hide
Type@1ms `:lua Cap("<leader>bb","breakpoint on this line")` Enter
Show
Sleep 1.5s
Type " bb"
Sleep 1.5s

Hide
Type@1ms ":9"
Enter
Type@1ms "^w"
Type@1ms `:lua Cap("<leader>df","debug the test function under the cursor")` Enter
Show
Sleep 1.5s
Type " df"
Wait+Screen@60s /Locals:/
Sleep 5s

Hide
Type@1ms `:lua Cap("<leader>dc","continue: the test passes")` Enter
Show
Sleep 1s
Type " dc"
Sleep 4s

Hide
Type@1ms `:lua Cap("<leader>dp","picker with every test in the file")` Enter
Show
Sleep 1s
Type " dp"
Sleep 3.5s
Escape
Sleep 1s
