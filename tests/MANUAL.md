# Manual checks

`tests/e2e-deep.sh` presses nearly every keymap and drives every debug feature,
but a script can only assert state it can read back. What is left here is what
needs a pair of eyes: colours, glyphs, spacing and anything that renders
outside nvim.

Run it once after a font change, a plugin bump, or a new machine. It takes about
five minutes.

```bash
./tests/fixtures/monorepo.sh ~/.cache/nvim-e2e-deep/monorepo
cd ~/.cache/nvim-e2e-deep/monorepo
nvim backend/core/services.py
```

| # | Check | What you should see |
|---|---|---|
| 1 | Theme | Darcula grey background, not pure black. Keywords orange, strings green, comments grey italic |
| 2 | Nerd Font glyphs | `<leader>ee` opens the tree with file-type icons. No empty boxes anywhere in the tree, the bufferline or the statusline |
| 3 | Statusline | lualine shows mode, branch, full path, encoding, filetype and position |
| 4 | Editor tabs | bufferline draws one tab per open buffer, with the "Project" offset header while the tree is open |
| 5 | Gutter stripes | edit a line in `notes.md`: gitsigns paints a coloured stripe in the gutter for the change |
| 6 | Inline blame | `<leader>gb`, then sit on a line for a second. The commit summary appears in dim virtual text to the right |
| 7 | Indent guides | thin vertical lines follow every indent level in `services.py` |
| 8 | Sticky context | scroll inside `summarize()` until the `def` line leaves the screen. It stays pinned at the top of the window |
| 9 | Completion popup | type `sum` inside a function: the blink.cmp popup opens with a readable border and the selected item highlighted |
| 10 | Copilot | in insert mode at the end of a function, ghost text appears after a moment |
| 11 | Breakpoint signs | set a plain, a conditional and a log breakpoint on three lines. All three gutter signs are visually distinct |
| 12 | dap-ui proportions | start a session: the left column (scopes/watches/breakpoints) and right column (repl/console) are readable at your terminal size, no squashed panel |
| 13 | Markdown preview | `<leader>mp` on `notes.md` opens the browser and renders the heading and paragraph |
| 14 | Chrome debug | run `npm run dev` in `frontend/`, then `<leader>dc` -> `4` on `App.tsx`. A Chrome window opens, the page renders, and nvim stops on the breakpoint |

## What the deep suite deliberately does not cover

- **Anything the terminal draws.** Colours, glyphs and window proportions are
  in the table above.
- **Session restore across restarts.** auto-session writes on exit, so asserting
  it needs a second nvim boot inside the same suite. Check it by hand: open a
  few buffers, quit, reopen nvim in the same directory, and see them come back.
- **`<leader>ca` and `gi` results.** The suite only proves the keys fire without
  wedging nvim: whether a code action or an implementation exists depends on the
  language server and the cursor position, so a stable assertion would be
  testing pyright, not this config.
- **`<leader>mp`/`<leader>mP` and the treesitter motions** (`gnn`/`grn`/`grc`/
  `grm`, `af`/`if`/`ac`/`ic`). The suite only checks these are bound
  (`maparg`), it never presses them; markdown preview opening a browser and the
  treesitter selection/textobject behavior are covered by check 13 above and by
  `tests/features.lua`'s static maparg checks, respectively.
- **Attach configurations.** "Attach to process" needs a process picker choice
  and "Attach to Chrome port 9222" needs a browser already started with the
  remote debugging port. Both are one-off manual runs, described in the
  Debugging section of the README.
