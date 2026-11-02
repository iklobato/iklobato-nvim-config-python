# Diagnostics, format on demand, replace a word in the whole file.
Output docs/demos/05-diagnostics-edit.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/legacy.py` Enter
Sleep 8s
Type@1ms "G"
Show

Hide
Type@1ms `:lua Cap("]d","jump to the next diagnostic")` Enter
Show
Sleep 1s
Type "]d"
Sleep 2s
Hide
Type@1ms `:lua Cap("<leader>gf","show the message under the cursor")` Enter
Show
Sleep 1s
Type " gf"
Sleep 3s
Type "j"
Sleep 500ms

Hide
Type@1ms `:lua Cap("<leader>F","format the buffer (ruff)")` Enter
Type@1ms "Go"
Show
Type@90ms "values=[1,2,   3]"
Escape
Sleep 1.5s
Type " F"
Sleep 2.5s

Hide
Type@1ms ":6"
Enter
Type@1ms "^"
Type@1ms `:lua Cap("<leader>S","replace the word under the cursor in the whole file")` Enter
Show
Sleep 1.5s
Type " S"
Sleep 1.5s
Ctrl+W
Type@120ms "acc"
Sleep 1.5s
Enter
Sleep 3s
