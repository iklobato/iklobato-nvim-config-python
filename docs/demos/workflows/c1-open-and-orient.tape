# Chapter 1: open a project and get oriented. Install deps and first run in the
# shell, then the tree, splits, the explorer, and the buffer list. Keys live.
Output docs/demos/workflows/c1-open-and-orient.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Show
Sleep 1200ms

# deps and first run, in the shell
Type "cd backend && source .venv/bin/activate" Enter
Sleep 1.5s
Type "pip install -r requirements.txt" Enter
Wait+Screen@45s /already satisfied|Successfully installed/
Sleep 2.2s
Type "python demo.py" Enter
Wait+Screen@15s /total 20/
Sleep 3s
Type "cd .." Enter
Sleep 750ms

# open the project
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' ." Enter
Wait+Screen@20s /NvimTree|backend/
Sleep 3s
Type@1ms ":wincmd l" Enter
Sleep 450ms
Type@1ms ":e backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 2.2s

# splits
Type " sv"
Sleep 1.8s
Type " sh"
Sleep 1.8s
Type " se"
Sleep 1.8s
Type@1ms ":only" Enter
Sleep 1200ms

# explorer toggle
Type " ee"
Sleep 2.2s
Type " ee"
Sleep 1.5s

# buffers
Type@1ms ":e notes.md" Enter
Sleep 1.5s
Type " fb"
Wait+Screen@15s /services.py/
Sleep 2.2s
Escape
Escape
Sleep 1.8s

Hide
Type@1ms ":qa!" Enter
Sleep 1.5s
