# File explorer and the tabs on the top bar.
# Needs the demo project: bash tests/fixtures/monorepo.sh /tmp/demo
Output docs/demos/01-explorer-tabs.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' demo.py core/services.py core/views.py` Enter
Sleep 4s
Type@1ms `:lua Cap("leader = Space","three files open: one tab each on the top bar")` Enter
Show
Sleep 2.5s

Hide
Type@1ms `:lua Cap("<leader>ee","file explorer on")` Enter
Show
Sleep 1s
Type " ee"
Sleep 2.5s
Hide
Type@1ms `:lua Cap("<leader>ee","file explorer off")` Enter
Show
Sleep 1s
Type " ee"
Sleep 1.5s

Hide
Type@1ms `:lua Cap("<leader>ef","reveal the current file in the explorer")` Enter
Show
Sleep 1s
Type " ef"
Sleep 2.5s
Type " ee"
Sleep 1s

Hide
Type@1ms `:lua Cap("<leader>tn","next tab")` Enter
Show
Sleep 1s
Type " tn"
Sleep 1.5s
Type " tn"
Sleep 1.5s
Hide
Type@1ms `:lua Cap("<leader>tp","previous tab")` Enter
Show
Sleep 1s
Type " tp"
Sleep 1.5s
Hide
Type@1ms `:lua Cap("<leader>td","close this tab")` Enter
Show
Sleep 1s
Type " td"
Sleep 2s
Hide
Type@1ms `:lua Cap("<leader>to","new empty tab")` Enter
Show
Sleep 1s
Type " to"
Sleep 2.5s
