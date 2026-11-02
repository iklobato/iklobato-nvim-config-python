# LSP: hover, definition in a split, references, rename.
Output docs/demos/04-lsp.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/views.py` Enter
Sleep 8s
Type@1ms ":8"
Enter
Type@1ms "0fs"
Show

Hide
Type@1ms `:lua Cap("K","hover: docs and signature")` Enter
Show
Sleep 1s
Type "K"
Sleep 3s
Type "l"
Type "h"
Sleep 500ms

Hide
Type@1ms `:lua Cap("<leader>gd","go to definition in a vertical split")` Enter
Show
Sleep 1s
Type " gd"
Sleep 3s
Hide
Type@1ms ":close" Enter
Show

Hide
Type@1ms `:lua Cap("<leader>gr","every reference, in telescope")` Enter
Show
Sleep 1s
Type " gr"
Sleep 3.5s
Escape
Escape
Sleep 1s

Hide
Type@1ms `:lua Cap("<leader>rn","rename in every file")` Enter
Show
Sleep 1s
Type " rn"
Sleep 1.5s
Ctrl+U
Type@120ms "add_up"
Sleep 1s
Enter
Sleep 3s
