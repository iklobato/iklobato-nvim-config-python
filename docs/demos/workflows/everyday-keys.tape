# Everyday keys the other demos skip: comment lines, definition in a split and
# maximize it, grep results into the quickfix list, hide the values of a .env file.
Output "docs/demos/workflows/everyday-keys.gif"
Source docs/demos/settings.tape
Set Framerate 15

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
# fake values only, removed again at the end
Type@1ms "printf 'DATABASE_URL=postgres://demo:demo-pass@localhost:5432/demo\nAPI_TOKEN=fake-token-123\nDEBUG=true\n' > /tmp/demo/.env" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 3s
Show
Sleep 1.5s

# step 1: comment one line, then a block, then undo
Hide
Type@1ms ":2" Enter
Sleep 2.2s
Show
Type "gcc"
Sleep 2s
Type "gcc"
Sleep 2s
Hide
Type@1ms ":6" Enter
Sleep 2.2s
Show
Type "V4j"
Sleep 1s
Type "gc"
Sleep 2.5s
Type "u"
Sleep 2s

# step 2: definition in a split on the side, maximize it and restore
Hide
Type@1ms ":9" Enter
Type@1ms "0fd"
Sleep 2.2s
Show
Type " gd"
Sleep 3s
Type " sm"
Sleep 2.5s
Type " sm"
Sleep 2.5s
Hide
Type@1ms ":only" Enter
Sleep 2.2s
Show

# step 3: grep, send every hit to the quickfix list, walk it
Type " fg"
Hide
Wait+Screen@15s /Live Grep/
Show
Type@150ms "summarize"
Sleep 2s
Ctrl+Q
Sleep 2.5s
Type "]q"
Sleep 2s
Type "]q"
Sleep 2s
Type "[q"
Sleep 2s
Hide
Type@1ms ":cclose" Enter
Sleep 2.2s
Show

# step 4: a .env file opens with its values hidden; toggle them
Type@100ms ":e .env" Enter
Hide
Wait+Screen@15s /DATABASE_URL/
Show
Sleep 2.5s
Type " ch"
Sleep 3s
Type " ch"
Sleep 3s

Hide
Type@1ms ":qa!" Enter
Type@1ms "rm -f /tmp/demo/.env; git -C /tmp/demo checkout -- ." Enter
Sleep 1.5s
