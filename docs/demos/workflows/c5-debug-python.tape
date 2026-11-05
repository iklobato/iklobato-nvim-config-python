# Chapter 5: debug Python in depth. Conditional breakpoint, logpoint, breakpoint
# list, launch, step into / out / over, scopes and REPL. Keys live.
Output docs/demos/workflows/c5-debug-python.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' core/services.py demo.py" Enter
Wait+Screen@30s /def summarize/
Sleep 3s
Show
Sleep 1.5s

# conditional breakpoint
Type@1ms ":9" Enter
Type "^"
Type " bc"
Sleep 1.5s
Type@150ms "number == 3"
Enter
Sleep 2.2s

# logpoint
Type@1ms ":3" Enter
Type " bl"
Sleep 1.5s
Type@150ms "doubled={doubled}"
Enter
Sleep 2.2s

# breakpoint list
Type " ba"
Wait+Screen@15s /services.py/
Sleep 3.8s
Type@1ms ":cclose" Enter

# launch demo.py
Type@1ms ":b demo.py" Enter
Wait+Screen@15s /summarize/
Type " dc"
Wait+Screen@20s /Launch file/
Sleep 1.5s
Type "1"
Enter
Wait+Screen@40s /Locals:/
Sleep 5.2s

# step into / out / over
Type " dk"
Wait+Screen@15s /def double/
Sleep 3s
Type " do"
Sleep 3s
Type " dj"
Sleep 3s

# continue, terminate
Type " dc"
Sleep 4.5s
Type " dt"
Sleep 3s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
