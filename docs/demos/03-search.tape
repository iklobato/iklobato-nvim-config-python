# Telescope: find files, grep the project, symbols, open buffers.
Output docs/demos/03-search.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' demo.py` Enter
Sleep 6s
Show

Hide
Type@1ms `:lua Cap("<leader>ff","find files")` Enter
Show
Sleep 1s
Type " ff"
Sleep 1.5s
Type@120ms "services"
Sleep 2s
Enter
Sleep 2s

Hide
Type@1ms `:lua Cap("<leader>fg","grep the whole project as you type")` Enter
Show
Sleep 1s
Type " fg"
Sleep 1.5s
Type@120ms "def index"
Sleep 2.5s
Enter
Sleep 2.5s

Hide
Type@1ms `:lua Cap("<leader>fo","symbols of this file")` Enter
Show
Sleep 1s
Type " fo"
Sleep 2.5s
Type@120ms "api"
Sleep 1.5s
Enter
Sleep 2s

Hide
Type@1ms `:lua Cap("<leader>fb","pick an open buffer")` Enter
Show
Sleep 1s
Type " fb"
Sleep 3s
Escape
Sleep 1s
