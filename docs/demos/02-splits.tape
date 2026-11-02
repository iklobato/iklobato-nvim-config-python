# Window splits: open, maximize, even them out.
Output docs/demos/02-splits.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/services.py` Enter
Sleep 4s
Show

Hide
Type@1ms `:lua Cap("<leader>sv","split vertical")` Enter
Show
Sleep 1s
Type " sv"
Sleep 2s
Hide
Type@1ms `:lua Cap("<leader>sh","split horizontal")` Enter
Show
Sleep 1s
Type " sh"
Sleep 2s

Hide
Type@1ms `:lua Cap("<leader>sm","maximize this split")` Enter
Show
Sleep 1s
Type " sm"
Sleep 2s
Hide
Type@1ms `:lua Cap("<leader>sm","press again to restore")` Enter
Show
Sleep 1s
Type " sm"
Sleep 2s

Hide
Type@1ms ":wincmd l | vertical resize 30" Enter
Type@1ms `:lua Cap("<leader>se","uneven splits: make them equal")` Enter
Show
Sleep 2s
Type " se"
Sleep 2.5s
