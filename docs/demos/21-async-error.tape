# Workflow: an error raised inside an asyncio task nobody awaits. Python only logs
# it, so a normal debug run never stops; <leader>be makes the debugger stop on it.
Output docs/demos/21-async-error.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && clear" Enter
Type@1ms `nvim -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' async_demo.py` Enter
Sleep 6s
Type@1ms `:lua Cap("async_demo.py","fetch() raises in a task nobody awaits: python only logs it")` Enter
Show
Sleep 4s

Hide
Type@1ms `:lua Cap("<leader>be","when should an exception stop the debugger?")` Enter
Show
Sleep 1.5s
Type " be"
Wait+Screen@15s /user unhandled/
Sleep 2.5s
Type "2"
Sleep 600ms
Enter
Sleep 1s

Hide
Type@1ms `:lua Cap("<leader>dc","start: Launch file")` Enter
Show
Sleep 1.5s
Type " dc"
Wait+Screen@20s /Uvicorn/
Sleep 1.5s
Type "1"
Enter
Wait+Screen@60s /Locals:/
Hide
Type@1ms `:lua Cap("stopped","on the raise inside the task, value = 1 in Locals")` Enter
Show
Sleep 5s

Hide
Type@1ms `:lua Cap("<leader>dc","continue to the end")` Enter
Show
Sleep 1s
Type " dc"
Sleep 4s

Hide
Type@1ms ":qa!" Enter
