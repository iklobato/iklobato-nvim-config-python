# nvim config: knowledge index

Snapshot: `main` @ `5188f2d` (2026-11-16). Status below is the narrated-videos session (2026-11-15/16); the cloak and UI status lines are from their own sessions (2026-11-14) and were not re-checked. The older 2026-11-05 notes live in `../docs/KNOWLEDGE.md` and were not re-read or changed.

## Status at a glance
- **Done:** narrated tutorial videos: a 70.8 s trailer and 6 chapters (c2, c4, c5, c6, c7, c9) with voice, cards, zoom and music, a tests GIF, README links; merged as PR #19 (`5188f2d`). See `demos-narrated.md`.
- **Discovered:** the env `OPENROUTER_API_KEY` is a management key (no model calls); VHS needs `Set Framerate 15`; which-key confuses the keycast; this ffmpeg has no `drawtext`.
- **Next steps:** check the trailer plays on GitHub; rebase PR #18 (`perf/faster-boot-ty`), now conflicting with `main`; decide about deleting the inference key `nvim-demos`.
- **What is left:** inline video player in the README (manual upload); no narrated version of c1, c3, c8. Older open items: yaml/json/tfvars secrets not masked (`cloak.md`).
- **Monitor:** the key box pixel place shared by `docs/demos/keycast.lua` and `docs/demos/narrated/polish.py`; spend on the `nvim-demos` key (4.31 of 8 USD on 2026-11-16).

## Topics
- `cloak.md`: how the masking works, leak paths closed, gotchas.
- `ui.md`: icon and comfort changes (DAP signs, lualine, winbar, gitsigns, illuminate), lockfile and test gotchas.
- `demos-narrated.md`: narrated tutorial videos: what exists, how a chapter is made, contracts between files, gotchas (VHS, which-key, ffmpeg, voice), keys and cost.

## Session log
- 2026-11-16 (shortcuts GIF): new tape `docs/demos/workflows/shortcuts-navigation.tape` + its GIF (31 s, 1.8 MB), linked in README chapter 2: `<leader>fo`, `gd` + `<C-o>`, `<leader>gr`, `<leader>ff`, `<leader>fg`, `<leader>tp/tn/td`. Recorded from the `perf/faster-boot-ty` checkout (ty LSP, default 50 fps, keycast shows raw keys, not the `desc` version now on `main`); re-record from `main` with `Set Framerate 15` if it should match the narrated chapters. Frames checked with ffmpeg: every step lands on the expected file.
- 2026-11-16 (narrated demos, cont.): inference key from the management key; cedar voice; grill decisions in `../docs/decisions/2026-11-15-narrated-videos-pro.md`; `polish.py`; chapters c2, c4, c5, c6, c7, c9, trailer, tests GIF, README links; PR #19 merged. See `demos-narrated.md`.
- 2026-11-15 (narrated demos): branch `feat/narrated-demos` (worktree `~/.config/nvim-narrated`). keycast shows the mapping `desc`; c5 re-recorded at 15 fps with hidden waits; voice sync proven with a throwaway voice; real voice blocked on the OpenRouter key. See `demos-narrated.md`.
- 2026-11-14 (2nd): UI icons package A plus vim-illuminate on branch `feat/ui-icons-comfort`; also added the missing `<leader>ch` deep test. See `ui.md`.
- 2026-11-14: added `lua/config/cloak.lua`, keymap `<leader>ch`, Telescope previewer guard, live_grep glob exclusions, 3 checks in `tests/features.lua`. See `cloak.md`; earlier history in `../docs/KNOWLEDGE.md`.
