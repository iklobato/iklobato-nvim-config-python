# Database UI on the demo SQLite file: browse a table, run your own query.
# db_ui_save_location points at an empty dir, so the connections saved on this
# machine (~/.local/share/db_ui) never show up in the GIF.
Output docs/demos/09-database.gif
Source docs/demos/settings.tape

Hide
Type@1ms "tic -x -o /tmp/demo/.terminfo docs/demos/xterm-vhs.terminfo && export TERMINFO=/tmp/demo/.terminfo TERM=xterm-vhs" Enter
Type@1ms "cd /tmp/demo && export DBUI_URL=sqlite:/tmp/demo/data.db DBUI_NAME=demo && clear" Enter
Type@1ms `nvim --cmd "let g:db_ui_save_location='/tmp/demo/.dbui'" -c 'lua Cap=function(k,t) vim.api.nvim_echo({{" "..k.." ","IncSearch"},{"  "..t}},false,{}) end' notes.md` Enter
Sleep 4s
Show

Hide
Type@1ms `:lua Cap("<leader>db","database UI on (demo = data.db, SQLite)")` Enter
Show
Sleep 1.5s
Type " db"
Sleep 3s
Type "G"
Sleep 300ms
Enter
Wait+Screen@15s /Tables/
Sleep 500ms
Type "/Tables"
Enter
Sleep 300ms
Enter
Wait+Screen@15s /totals/
Sleep 1.2s
Type "j"
Enter
Sleep 1.2s
Type "j"
Sleep 800ms
Enter
Sleep 4s

Hide
Type@1ms "ggdG"
Type@1ms `:lua Cap("<leader>S","write your own query and run it")` Enter
Type@1ms "i"
Show
Type@80ms "select label, value from totals where value > 30;"
Escape
Sleep 1s
Type " S"
Sleep 4s
