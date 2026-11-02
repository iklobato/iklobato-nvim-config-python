# Workflow: completion while typing python, with LSP items and signature help.
Output docs/demos/12-completion.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/views.py` Enter
Sleep 8s
Type@1ms ":8"
Enter
Type@1ms `:lua Cap("<C-y>","completion pops up as you type, <C-y> accepts")` Enter
Show
Sleep 1.5s
Type "o"
Type@120ms "count = len(num"
Sleep 2s
Ctrl+Y
Sleep 800ms
Type ")"
Sleep 1.5s
Enter
Type@120ms "numbers.so"
Sleep 2.5s
Ctrl+Y
Sleep 800ms
Type@120ms "rev"
Sleep 1.5s
Ctrl+Y
Sleep 600ms
Type@120ms "True"
Sleep 2.5s
Escape
Sleep 1.5s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
