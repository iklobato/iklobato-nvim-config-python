# Narrated chapter 9: run and debug tests with neotest. Run the nearest test, the
# whole file, read the failure, the summary, then debug the failing test.
# The hidden setup adds a bug to summarize (+ 1) so one test really fails; the
# hidden end puts the file back. Same sync rules as c5-debug-python.tape:
# Framerate 15, every Wait inside Hide, hidden moves end with a 2.2 s pause.
# Each "# step N" matches sentence N of c9-run-tests.json. The Sleep that ends
# each step is sized from the measured spoken length of its line + 0.9 s.
Output "docs/demos/narrated/c9-run-tests.silent.mp4"
Source docs/demos/settings.tape
Set Framerate 15

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && cp docs/demos/keycast.lua /tmp/.keycast-demo.lua && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo/backend && source .venv/bin/activate && sed -i.bak 's/double(number)$/double(number) + 1/' core/services.py && rm core/services.py.bak && clear" Enter
Type@1ms "nvim -c 'luafile /tmp/.keycast-demo.lua' tests/test_services.py" Enter
Wait+Screen@30s /test_double_negative/
Type@1ms ":5" Enter
Sleep 2.2s
Show

# step 0: intro
Sleep 7.9s

# step 1: run the nearest test
Type " nn"
Hide
Sleep 1.2s
Show
Sleep 5.8s

# step 2: run the whole file
Type " nf"
Hide
Sleep 1.2s
Show
Sleep 6.4s

# step 3: read the failure
Hide
Type@1ms ":11" Enter
Sleep 2.2s
Show
Type " no"
Hide
Sleep 0.8s
Show
Sleep 4.2s

# step 4: the summary
Hide
Type@1ms ":close" Enter
Sleep 2.2s
Show
Type " ns"
Hide
Sleep 0.8s
Show
Sleep 5.2s

# step 5: debug the failing test
Hide
Type@1ms ":lua require('neotest').summary.close()" Enter
Type@1ms ":11" Enter
Sleep 2.2s
Show
Type " bb"
Sleep 1.5s
Type " nd"
Hide
Wait+Screen@40s /Locals:/
Show
Sleep 5.2s

# step 6: ask the debugger for the value
Hide
Type@1ms ":lua for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'dap-repl' then vim.api.nvim_set_current_win(w) end end" Enter
Type@1ms ":startinsert!" Enter
Sleep 2.2s
Show
Type@150ms "result"
Enter
Sleep 3.7s

# step 7: outro
Sleep 5.8s

Hide
Escape
Type " dt"
Sleep 1.5s
Type@1ms ":qa!" Enter
Sleep 1.5s
Type@1ms "git -C /tmp/demo checkout -- backend/core/services.py" Enter
Sleep 1s
