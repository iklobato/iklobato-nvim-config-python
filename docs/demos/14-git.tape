# Workflow: git in the editor: inline blame, change marks in the margin.
Output docs/demos/14-git.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/services.py` Enter
Sleep 6s
Type@1ms ":7"
Enter
Type@1ms "^"
Type@1ms `:lua Cap("blame","last commit of this line, right after the code")` Enter
Show
Sleep 3s

Hide
Type@1ms `:lua Cap("edit","the margin marks added, changed and deleted lines")` Enter
Show
Sleep 1.5s
Type "f0"
Sleep 400ms
Type "r1"
Sleep 1s
Type "j"
Type "O"
Type@120ms "# add up every number"
Escape
Sleep 1s
Type@1ms ":4"
Enter
Type "dd"
Sleep 1.5s
Type@1ms ":8"
Enter
Sleep 3s

Hide
Type@1ms `:lua Cap("<leader>gb","blame off, press again for on")` Enter
Show
Sleep 1s
Type " gb"
Sleep 2.5s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
