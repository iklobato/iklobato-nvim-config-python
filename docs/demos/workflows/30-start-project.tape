# Workflow V1: start a project. Install deps, first run in the shell, then open it
# in nvim and watch the language server attach. The hidden setup only resets the
# repo and compiles the xterm-vhs terminfo so truecolor survives inside VHS.
Output docs/demos/workflows/30-start-project.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Show
Sleep 1.2s

# deps + first run, in the shell
Type "cd backend && source .venv/bin/activate" Enter
Sleep 1.2s
Type "pip install -r requirements.txt" Enter
Wait+Screen@45s /already satisfied|Successfully installed/
Sleep 2s
Type "python demo.py" Enter
Wait+Screen@15s /total 20/
Sleep 2.5s
Type "cd .." Enter
Sleep 600ms

# open the project: session opens the file tree
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' .` Enter
Wait+Screen@20s /NvimTree|backend/
Sleep 1.5s
Hide
Type@1ms `:lua Cap("nvim .","session opens the project tree")` Enter
Show
Sleep 2.5s

# cursor starts in the tree; move to the main window, then open a file
Type@1ms ":wincmd l" Enter
Sleep 300ms
Type@1ms ":e backend/core/services.py" Enter
Wait+Screen@30s /def summarize/
Sleep 1.2s
Hide
Type@1ms `:lua Cap("pyright","the language server attaches on the first file")` Enter
Show
Sleep 2.5s

# hover
Type@1ms ":6" Enter
Type@1ms "0w"
Hide
Type@1ms `:lua Cap("K","hover: types and docs from pyright")` Enter
Show
Sleep 800ms
Type "K"
Sleep 3.5s
Type "q"
Sleep 800ms

# completion as you type
Hide
Type@1ms ":9" Enter
Type@1ms `:lua Cap("blink.cmp","completion as you type")` Enter
Show
Type "o"
Type@120ms "summ"
Sleep 3s
Escape
Sleep 1.2s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
