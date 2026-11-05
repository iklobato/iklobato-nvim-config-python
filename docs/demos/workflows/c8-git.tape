# Chapter 8: Git in the editor. Inline blame, the change marks in the gutter, and
# the blame toggle. Keys live.
Output docs/demos/workflows/c8-git.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 3s
Show
Sleep 1.5s

# inline blame on
Type " gb"
Sleep 3.8s

# change a line: a hunk mark shows in the gutter
Type@1ms ":2" Enter
Type "A"
Type@150ms "  # tweaked"
Escape
Sleep 3.8s

# add a line
Type "o"
Type@150ms "extra = 1"
Escape
Sleep 3.8s

# blame off
Type " gb"
Sleep 3s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
