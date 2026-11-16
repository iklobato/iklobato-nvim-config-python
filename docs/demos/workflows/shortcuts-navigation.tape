# Shortcut tour: the navigation keys used most. Symbols list, go to definition and
# back, references, find files, grep, and the buffer tabs. The winbar breadcrumb at
# the top shows which file is open after each jump.
Output docs/demos/workflows/shortcuts-navigation.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 4s
Show
Sleep 2s

# symbols of this file: classes and functions
Type " fo"
Wait+Screen@15s /summarize/
Sleep 1.5s
Type@200ms "summ"
Sleep 1.8s
Enter
Sleep 2s

# go to definition, then back with Ctrl-o
Type@1ms ":9" Enter
Type "0fd"
Sleep 1s
Type "gd"
Sleep 2.5s
Ctrl+O
Sleep 2.5s

# references of summarize, in every file
Type@1ms ":6" Enter
Type "0w"
Sleep 800ms
Type " gr"
Wait+Screen@20s /views.py/
Sleep 3.5s
Escape
Escape
Sleep 1.5s

# find a file by name
Type " ff"
Wait+Screen@15s /Find Files/
Sleep 1s
Type@200ms "views"
Sleep 2s
Enter
Wait+Screen@20s /def index/
Sleep 2.5s

# grep the whole project, open the hit
Type " fg"
Wait+Screen@15s /Live Grep/
Sleep 1s
Type@150ms "def test_double"
Sleep 2.2s
Enter
Wait+Screen@20s /test_double/
Sleep 2.5s

# buffer tabs on top: previous, next, close
Type " tp"
Sleep 2s
Type " tp"
Sleep 2s
Type " tn"
Sleep 2s
Type " td"
Sleep 3s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
