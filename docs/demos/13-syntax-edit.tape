# Workflow: edit by syntax: grow the selection, delete a whole function, f-strings.
Output docs/demos/13-syntax-edit.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' core/services.py` Enter
Sleep 6s
Type@1ms ":9"
Enter
Type@1ms "^w"
Type@1ms `:lua Cap("v an an an, in","grow the selection by syntax node, in shrinks it")` Enter
Show
Sleep 1.5s
Type "v"
Sleep 600ms
Type "an"
Sleep 1.2s
Type "an"
Sleep 1.2s
Type "an"
Sleep 1.2s
Type "an"
Sleep 1.5s
Type "in"
Sleep 1.5s
Escape
Sleep 500ms

Hide
Type@1ms ":7"
Enter
Type@1ms `:lua Cap("daf","delete the whole function, u brings it back")` Enter
Show
Sleep 1.5s
Type "daf"
Sleep 2s
Type "u"
Sleep 1.5s

Hide
Type@1ms ":7"
Enter
Type@1ms `:lua Cap("{ in a string","it turns into an f-string by itself")` Enter
Show
Sleep 1.5s
Type "o"
Type@120ms 'label = "start at {total}"'
Sleep 2.5s
Escape
Sleep 1.5s

Hide
Type@1ms ":qa!" Enter
Sleep 1s
