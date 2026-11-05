# Chapter 3: write code. Completion, grow the selection by syntax node, and
# delete a function with a text object. Keys live.
Output docs/demos/workflows/c3-write-code.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 2s
Show
Sleep 1s

# completion
Type@1ms ":8" Enter
Type "o"
Type@110ms "x = doub"
Sleep 1.8s
Ctrl+Y
Sleep 1.3s
Escape
Type@1ms ":e!" Enter
Wait+Screen@15s /def summarize/
Sleep 800ms

# grow the selection by syntax node
Type@1ms ":9" Enter
Type "^"
Type "v"
Type "an"
Sleep 900ms
Type "an"
Sleep 1s
Escape
Sleep 800ms

# delete a function
Type@1ms ":6" Enter
Type "daf"
Sleep 2s
Type "u"
Sleep 2s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
