# Chapter 2: navigate a codebase. Find, grep, go to definition and references,
# list symbols, rename. Keys shown live by the keycast overlay.
Output docs/demos/workflows/c2-navigate.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 2s
Show
Sleep 1s

# find files
Type " ff"
Wait+Screen@15s /Find Files/
Sleep 700ms
Type@100ms "views"
Sleep 1.3s
Enter
Wait+Screen@20s /def index/
Sleep 1.5s

# live grep
Type " fg"
Wait+Screen@15s /Live Grep/
Sleep 700ms
Type@100ms "summarize"
Sleep 1.5s
Escape
Escape
Sleep 1s

# back to services.py, go to definition
Type@1ms ":b services.py" Enter
Wait+Screen@15s /def double/
Type@1ms ":9" Enter
Type "0fd"
Sleep 600ms
Type "gd"
Sleep 2s

# references
Type " gr"
Wait+Screen@20s /services.py/
Sleep 2.5s
Escape
Escape
Sleep 1s

# document symbols
Type " fo"
Wait+Screen@15s /summarize/
Sleep 2.5s
Escape
Escape
Sleep 1s

# rename
Type@1ms ":1" Enter
Type "0w"
Type " rn"
Sleep 1.2s
Ctrl+U
Type@90ms "scale"
Enter
Sleep 2.5s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
