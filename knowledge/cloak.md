# nvim config: cloak (hide secret values in .env files)

Snapshot: `main` @ `1b564a6` (2026-11-14), changes uncommitted at the time of writing. Verified with the headless suite only (`ONLY=cloak ./tests/run.sh`); never checked in a real UI session. Telescope previewer and live_grep changes were not exercised by a test.

## What it does
- `lua/config/cloak.lua`: for buffers named `.env`, `.env.*`, `*.env`, `.envrc` it puts one overlay extmark per `KEY=value` line (namespace `cloak`). The value shows as `*` repeated to its display width; the key and comment lines stay visible.
- Buffer text is untouched: yank copies the real value, save writes the real value. Nothing is redacted on disk.
- Toggle: `<leader>ch` (`lua/keymaps/tools.lua`). State is one module-level boolean, global for all buffers.
- Re-rendered on `BufWinEnter`, `TextChanged`, `TextChangedI` (autocmd group `Cloak`, wired from `lua/autocmds/init.lua`).
- Chose native extmarks over `laytan/cloak.nvim` because the repo rule is no new dependency without asking.

## Leak paths closed
- Telescope file preview: `buffer_previewer_maker` in `lua/config/telescope.lua` shows `secret file: preview hidden` when `cloak.is_secret_file(path)`.
- `<leader>fg` live grep: `additional_args` adds `--glob=!` for the same four patterns (`lua/keymaps/search.lua`), because a grep hit prints the whole line.

## Gotchas
- `M.patterns` is the single list for the autocmd and for `is_secret_file`. The live_grep globs are a separate hand-copied list: change both.
- Only `KEY=value` lines match. yaml/json (`password: x`), `*.tfvars`, `credentials` files are NOT covered.
- Mask length equals value length, so length leaks.
- Other readers of the file still show plain text: `:!cat`, `:r`, `:messages`, the quickfix list, `find_files` (names only, fine), any `grep` outside the mapped live_grep.
- Test run output:
  ```
  PASS  cloak: .env values covered, keys and comments left alone
  PASS  cloak: toggle reveals and hides again
  PASS  cloak: only env files are secret files
  3/3 checks passed
  ```
  (from `ONLY=cloak ./tests/run.sh`, 2026-11-14).

## Next steps
- Open a real `.env`, press `<leader>ch`, confirm the mask in a UI session.
- Decide whether to extend `M.patterns` and the line matcher to yaml/json/tfvars.
- Branch before committing: the work is on `main`.
