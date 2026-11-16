# Chapter 9: run and debug tests. Run the nearest test, the whole file (one fails
# on the line that failed), the summary, then debug the failing test. Keys live.
# The hidden setup adds a bug to summarize (+ 1); the hidden end restores it.
Output docs/demos/workflows/c9-run-tests.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && sed -i.bak 's/double(number)$/double(number) + 1/' core/services.py && rm core/services.py.bak && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' tests/test_services.py" Enter
Wait+Screen@30s /test_double_negative/
Type@1ms ":5" Enter
Sleep 2.2s
Show
Sleep 1.5s

# run the nearest test
Type " nn"
Sleep 3s

# run the whole file: one fails on its line
Type " nf"
Sleep 4s
Type@1ms ":11" Enter
Sleep 1.5s

# the summary
Type " ns"
Sleep 3s
Hide
Type@1ms ":lua require('neotest').summary.close()" Enter
Type@1ms ":11" Enter
Sleep 2.2s
Show

# debug the failing test
Type " bb"
Sleep 1.2s
Type " nd"
Wait+Screen@40s /Locals:/
Sleep 4s

Hide
Type " dt"
Sleep 1.5s
Type@1ms ":qa!" Enter
Sleep 1.5s
Type@1ms "git -C /tmp/demo checkout -- backend/core/services.py" Enter
Sleep 1s
