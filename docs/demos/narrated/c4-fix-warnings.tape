# Narrated chapter 4: clean up an old file. Jump to each Ruff warning, fix it with
# a code action, rename through the language server, format the file.
# The hidden setup squeezes the spacing in legacy.py so the formatter has work to
# show; the hidden end restores the file. Same sync rules as c5-debug-python.tape:
# Framerate 15, every Wait inside Hide, hidden moves end with a 2.2 s pause.
# Each "# step N" matches sentence N of c4-fix-warnings.json. The Sleep that ends
# each step is sized from the measured spoken length of its line + 0.9 s.
Output "docs/demos/narrated/c4-fix-warnings.silent.mp4"
Source docs/demos/settings.tape
Set Framerate 15

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && sed -i.bak -e 's/total = 0/total=0/' -e 's/total = total + number/total=total+number/' core/legacy.py && rm core/legacy.py.bak && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' core/legacy.py" Enter
Wait+Screen@30s /import json/
Wait+Screen@30s /ty ruff/
Sleep 3s
Show

# step 0: intro
Sleep 9s

# step 1: jump to the next problem
Type "]d"
Sleep 5.8s

# step 2: fix it with a code action
Type " ca"
Hide
Wait+Screen@20s /unused|Remove|Ruff/
Show
Sleep 1.5s
Type "1"
Enter
Sleep 3.7s

# step 3: the second one
Type "]d"
Sleep 1s
Type " ca"
Hide
Wait+Screen@20s /unused|Remove|Ruff/
Show
Sleep 1.5s
Type "1"
Enter
Sleep 2s

# step 4: rename through the language server
Hide
Type@1ms "/legacy_total" Enter
Sleep 2.2s
Show
Type " rn"
Sleep 1.5s
Ctrl+U
Type@150ms "running_total"
Enter
Sleep 4.6s

# step 5: format the file
Type " F"
Sleep 4.3s

# step 6: outro
Sleep 7.2s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
Type@1ms "git -C /tmp/demo checkout -- backend/core/legacy.py" Enter
Sleep 1s
