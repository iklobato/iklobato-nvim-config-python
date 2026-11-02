# Workflow: a failing test, find the bad value in the debugger, fix it, run it again.
# The hidden setup plants the bug (value * 3); the fix puts back value * 2, and
# the hidden end restores the file from git in case the tape stopped half way.
Output docs/demos/11-fix-a-bug.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && sed -i '' 's/value \* 2/value * 3/' core/services.py && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' tests/test_services.py` Enter
Sleep 8s
Type@1ms ":11"
Enter
Type@1ms "^"
Type@1ms `:lua Cap("test_summarize","expects summarize([1, 2]) == 6")` Enter
Show
Sleep 2.5s

Hide
Type@1ms `:lua Cap("<leader>bb","breakpoint on the assert")` Enter
Show
Sleep 1.5s
Type " bb"
Sleep 1s
Hide
Type@1ms ":9"
Enter
Type@1ms "^w"
Type@1ms `:lua Cap("<leader>df","debug this test")` Enter
Show
Sleep 1.5s
Type " df"
Wait+Screen@60s /Locals:/
Sleep 1s
Hide
Type@1ms `:lua Cap("Locals","result is 9, not 6")` Enter
Show
Sleep 3.5s

Hide
Type@1ms `:lua Cap("<leader>dc","continue: the test fails")` Enter
Show
Sleep 1s
Type " dc"
Wait+Screen@30s /assert 9 == 6/
Sleep 3s

Hide
Type@1ms ":10"
Enter
Type@1ms "^f=w"
Type@1ms `:lua Cap("gd","jump to summarize, then to double")` Enter
Show
Sleep 1.5s
Type "gd"
Sleep 2s
Hide
Type@1ms ":9"
Enter
Type@1ms "^fd"
Show
Type "gd"
Sleep 2s

Hide
Type@1ms ":2"
Enter
Type@1ms `:lua Cap("r2","the bug: value * 3, make it * 2, then save")` Enter
Show
Sleep 1.5s
Type "f3"
Sleep 500ms
Type "r2"
Sleep 1s
Type " ww"
Sleep 2s

Hide
Type@1ms `:lua Cap("<leader>tp","back to the test")` Enter
Show
Sleep 1s
Type " tp"
Sleep 1.5s
Hide
Type@1ms `:lua Cap("<leader>dl","run the same test again")` Enter
Show
Sleep 1s
Type " dl"
Wait+Screen@60s /Locals:/
Sleep 1s
Hide
Type@1ms `:lua Cap("Locals","result is 6 now")` Enter
Show
Sleep 3s
Hide
Type@1ms `:lua Cap("<leader>dc","continue: the test passes")` Enter
Show
Sleep 1s
Type " dc"
Wait+Screen@30s /1 pas/
Sleep 4s

Hide
Type@1ms ":qa!" Enter
Sleep 2s
Type@1ms "git -C /tmp/demo checkout -- backend/core/services.py" Enter
Sleep 1s
