# Chapter 4: diagnose and clean up. Ruff flags the unused imports, code actions
# remove them, rename the function, then format. Keys live.
Output docs/demos/workflows/c4-diagnose-and-clean.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' backend/core/legacy.py" Enter
Wait+Screen@30s /import json/
Sleep 3.8s
Show
Sleep 1.5s

Type "]d"
Sleep 2.2s
Type " ca"
Wait+Screen@20s /unused|Remove|Ruff/
Sleep 2.2s
Type "1"
Enter
Sleep 3.8s

Type "gg"
Sleep 450ms
Type "]d"
Sleep 1.8s
Type " ca"
Wait+Screen@15s /unused|Remove|Ruff/
Sleep 2.2s
Type "1"
Enter
Sleep 3.8s

Type@1ms "/legacy_total" Enter
Type " rn"
Sleep 1.8s
Ctrl+U
Type@150ms "running_total"
Enter
Sleep 3.8s

Type " F"
Sleep 3.8s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
