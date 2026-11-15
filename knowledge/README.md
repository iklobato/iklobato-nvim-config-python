# nvim config: knowledge index

Snapshot: `main` @ `1b564a6` (2026-11-14). Only this session was written here; the older 2026-11-05 session notes live in `../docs/KNOWLEDGE.md` and were not re-read or changed.

## Status at a glance
- **Done:** `.env` values are masked in nvim, with toggle, plus Telescope preview and live_grep leak fixes. 3 new headless checks pass.
- **Discovered:** `vim.glob.to_lpeg(glob):match(basename)` is enough to reuse the autocmd globs in Lua; `stylua` reformats the new edits (run it before `tests/run.sh`, which checks format).
- **Next steps:** UI check of the mask; branch and commit (nothing committed yet).
- **What's left:** yaml/json/tfvars secrets are not covered.
- **Monitor:** the two pattern lists (`M.patterns` and the live_grep globs) drifting apart.

## Topics
- `cloak.md`: how the masking works, leak paths closed, gotchas.
- `ui.md`: icon and comfort changes (DAP signs, lualine, winbar, gitsigns, illuminate), lockfile and test gotchas.
- `demos-narrated.md`: narrated tutorial videos: keycast with mapping names, 15 fps rule, voice sync, OpenRouter blocker.

## Session log
- 2026-11-15 (narrated demos): branch `feat/narrated-demos` (worktree `~/.config/nvim-narrated`). keycast shows the mapping `desc`; c5 re-recorded at 15 fps with hidden waits; voice sync proven with a throwaway voice; real voice blocked on the OpenRouter key. See `demos-narrated.md`.
- 2026-11-14 (2nd): UI icons package A plus vim-illuminate on branch `feat/ui-icons-comfort`; also added the missing `<leader>ch` deep test. See `ui.md`.
- 2026-11-14: added `lua/config/cloak.lua`, keymap `<leader>ch`, Telescope previewer guard, live_grep glob exclusions, 3 checks in `tests/features.lua`. See `cloak.md`; earlier history in `../docs/KNOWLEDGE.md`.
