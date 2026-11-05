# Workflow V5: working in a codebase. Find files, grep, jump to a definition and
# its references, list symbols, rename, and jump a diagnostic, over the monorepo.
Output docs/demos/workflows/34-navigate-codebase.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && git checkout -- . >/dev/null 2>&1; clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' backend/core/views.py` Enter
Wait+Screen@30s /def index/
Sleep 2s
Show
Sleep 1s

# find files
Hide
Type@1ms `:lua Cap("<leader>ff","find files")` Enter
Show
Sleep 900ms
Type " ff"
Wait+Screen@15s /Find Files/
Sleep 800ms
Type@80ms "services"
Sleep 1.5s
Enter
Wait+Screen@20s /def summarize/
Sleep 1.5s

# live grep
Hide
Type@1ms `:lua Cap("<leader>fg","live grep across the repo")` Enter
Show
Sleep 900ms
Type " fg"
Wait+Screen@15s /Live Grep/
Sleep 800ms
Type@80ms "summarize"
Sleep 2.2s
Escape
Escape
Sleep 800ms

# go to definition
Type@1ms ":9" Enter
Type@1ms "0fd"
Hide
Type@1ms `:lua Cap("gd","go to definition")` Enter
Show
Sleep 900ms
Type "gd"
Sleep 2.5s

# references
Hide
Type@1ms `:lua Cap("<leader>gr","references in telescope")` Enter
Show
Sleep 900ms
Type " gr"
Wait+Screen@20s /services.py/
Sleep 2.5s
Escape
Escape
Sleep 800ms

# document symbols
Hide
Type@1ms `:lua Cap("<leader>fo","document symbols")` Enter
Show
Sleep 900ms
Type " fo"
Wait+Screen@15s /summarize/
Sleep 2.5s
Escape
Escape
Sleep 800ms

# rename
Type@1ms ":1" Enter
Type@1ms "0w"
Hide
Type@1ms `:lua Cap("<leader>rn","rename the symbol across the buffer")` Enter
Show
Sleep 900ms
Type " rn"
Sleep 1.2s
Ctrl+U
Type@90ms "scale"
Sleep 1s
Enter
Sleep 2.5s

# jump a diagnostic
Hide
Type@1ms ":e backend/core/legacy.py" Enter
Wait+Screen@20s /import json/
Sleep 2.5s
Type@1ms `:lua Cap("]d","jump to the next diagnostic")` Enter
Show
Sleep 900ms
Type "]d"
Sleep 3s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
