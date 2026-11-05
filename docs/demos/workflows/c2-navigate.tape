# Chapter 2: navigate a codebase. Find, grep, go to definition and references,
# list symbols, rename. Keys shown live by the keycast overlay.
Output docs/demos/workflows/c2-navigate.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 3s
Show
Sleep 1.5s

# find files
Type " ff"
Wait+Screen@15s /Find Files/
Sleep 1050ms
Type@150ms "views"
Sleep 2s
Enter
Wait+Screen@20s /def index/
Sleep 2.2s

# live grep
Type " fg"
Wait+Screen@15s /Live Grep/
Sleep 1050ms
Type@150ms "summarize"
Sleep 2.2s
Escape
Escape
Sleep 1.5s

# back to services.py, go to definition
Type@1ms ":b services.py" Enter
Wait+Screen@15s /def double/
Type@1ms ":9" Enter
Type "0fd"
Sleep 900ms
Type "gd"
Sleep 3s

# references
Type " gr"
Wait+Screen@20s /services.py/
Sleep 3.8s
Escape
Escape
Sleep 1.5s

# document symbols
Type " fo"
Wait+Screen@15s /summarize/
Sleep 3.8s
Escape
Escape
Sleep 1.5s

# rename
Type@1ms ":1" Enter
Type "0w"
Type " rn"
Sleep 1.8s
Ctrl+U
Type@150ms "scale"
Enter
Sleep 3.8s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
