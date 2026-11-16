# Narrated chapter 5: debug Python. Same flow as workflows/c5, re-timed for a voice
# track. Rules that keep the video in sync with the narration:
# - Framerate 15: at the default 50 fps VHS drops frames at 1400x820 and the video
#   runs at about 0.4x real time, different on every render. At 15 fps it is ~0.98x.
# - Every Wait sits inside Hide, so only fixed Type/Sleep time reaches the video.
# - Cursor moves (:9, :3) run hidden, followed by a hidden pause so the key box
#   fades before Show: the viewer only sees the shortcuts the voice names.
# Each "# step N" matches sentence N of c5-debug-python.json. Sleeps are sized from the
# measured spoken length of each line (cedar take + 0.9 s).
Output "docs/demos/narrated/c5-debug-python.silent.mp4"
Source docs/demos/settings.tape
Set Framerate 15

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' core/services.py demo.py" Enter
Wait+Screen@30s /def summarize/
Sleep 3s
Show

# step 0: intro
Sleep 14.1s

# step 1: conditional breakpoint
Hide
Type@1ms ":9" Enter
Type "^"
Sleep 2.2s
Show
Type " bc"
Sleep 1.5s
Type@150ms "number == 3"
Enter
Sleep 5.7s

# step 2: logpoint
Hide
Type@1ms ":3" Enter
Sleep 2.2s
Show
Type " bl"
Sleep 1.5s
Type@150ms "doubled={doubled}"
Enter
Sleep 4.7s

# step 3: breakpoint list
Type " ba"
Hide
Wait+Screen@15s /services.py/
Show
Sleep 5.75s
Hide
Type@1ms ":cclose" Enter
Type@1ms ":b demo.py" Enter
Wait+Screen@15s /summarize/
Sleep 2.2s
Show

# step 4: launch
Type " dc"
Hide
Wait+Screen@20s /Launch file/
Show
Sleep 5.5s
Type "1"
Sleep 1s
Enter
Hide
Wait+Screen@40s /Locals:/
Show
Sleep 0.25s

# step 5: stopped at number == 3
Sleep 9.4s

# step 6: step into
Type " dk"
Hide
Wait+Screen@15s /def double/
Show
Sleep 5.1s

# step 7: step out
Type " do"
Sleep 3.2s

# step 8: step over
Type " dj"
Sleep 4s

# step 9: continue to the end, terminate
Type " dc"
Sleep 3s
Type " dt"
Sleep 3s

# step 10: outro
Sleep 6s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
