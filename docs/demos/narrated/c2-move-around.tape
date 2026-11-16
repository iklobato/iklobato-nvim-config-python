# Narrated chapter 2: move around a codebase you do not know. Go to definition and
# back, open a file by name, Vim motions inside a file, search in the file, search
# the project, change a word and undo. Same sync rules as c5-debug-python.tape:
# - Framerate 15 (the default 50 fps drops frames and the video runs ~0.4x).
# - Every Wait sits inside Hide, so only fixed Type/Sleep time reaches the video.
# - Cursor moves the voice does not talk about run hidden, then a hidden 2.2 s
#   pause lets the key box fade before Show.
# Each "# step N" matches sentence N of c2-move-around.json. The Sleep that ends
# each step is sized from the measured spoken length of its line + 0.7 s.
Output "docs/demos/narrated/c2-move-around.silent.mp4"
Source docs/demos/settings.tape
Set Framerate 15

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' demo.py" Enter
Wait+Screen@30s /summarize/
Wait+Screen@30s /ty ruff/
Type@1ms ":4" Enter
Type "fs"
Sleep 2.2s
Show

# step 0: intro
Sleep 11.8s

# step 1: go to definition (another file)
Type "gd"
Hide
Wait+Screen@15s /def double/
Show
Sleep 8.1s

# step 2: jump back
Ctrl+O
Hide
Wait+Screen@15s /numbers = /
Show
Sleep 4.1s

# step 3: open a file by name
Type " ff"
Hide
Wait+Screen@15s /Find Files/
Show
Sleep 1s
Type@150ms "core/serv"
Hide
Wait+Screen@15s /core\/services\.py/
Show
Sleep 1.5s
Enter
Hide
Wait+Screen@15s /def double/
Show
Sleep 2s

# step 4: motions inside the file
Type "gg"
Sleep 1.2s
Type "}"
Sleep 1.2s
Type "j"
Sleep 0.8s
Type "j"
Sleep 0.8s
Type "w"
Sleep 0.8s
Type "w"
Sleep 0.8s
Type "L"
Sleep 1.2s
Type "H"
Sleep 2.3s

# step 5: search in the file
Type "/"
Sleep 0.5s
Type@150ms "double"
Enter
Sleep 1.5s
Type "n"
Sleep 3.2s

# step 6: search the whole project
Type " fg"
Hide
Wait+Screen@15s /Live Grep/
Show
Sleep 1s
Type@150ms "total"
Hide
Wait+Screen@15s /demo\.py/
Show
Sleep 6.9s

# step 7: change a word, then undo
Hide
Escape
Escape
Wait+Screen@15s /def double/
Type@1ms ":2" Enter
Type "$"
Sleep 2.2s
Show
Type "ciw"
Sleep 0.8s
Type "3"
Sleep 0.4s
Escape
Sleep 1.5s
Type "u"
Sleep 4.5s

# step 8: outro
Sleep 8.2s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
