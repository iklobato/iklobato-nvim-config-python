# nvim config: knowledge index

Snapshot: `perf/faster-boot-ty` off `main` @ `fe40ecc` (2026-11-15). Status below is this session's; the older 2026-11-05 notes live in `../docs/KNOWLEDGE.md` and were not re-read or changed.

## Status at a glance
- **Done:** empty start 50 -> 43 ms and first python file 247 -> 220 ms (interleaved A/B medians); ty is the default python type server; `system/iterm2` removed. `tests/run.sh` 84/84, `tests/e2e.sh` 24/24, deep suite 480/481 then `lsp` 48/48 x3 after fixing two test races (see `perf.md`).
- **Discovered:** blink.cmp spawns git twice plus shasum on every load; `wshada!` drops `v:oldfiles`; live iTerm2 prefs come from `~/iterm2-dotfiles`. See `perf.md`.
- **Next steps:** user checks ty in daily use; per-keystroke plugin costs were only reported in chat, no plugin changed.
- **What's left:** other stale copies in `system/` (`zshrc`, `tmux.conf`) while `~/.zshrc` links to `~/iterm2-dotfiles`.
- **Monitor:** ty is 0.0.x; if a feature is missing, `NVIM_PY_LSP=pyright` switches back.

## Topics
- `cloak.md`: how the masking works, leak paths closed, gotchas.
- `perf.md`: boot and LSP speed: how to benchmark without wiping ShaDa, A/B numbers, ty vs pyright.
- `ui.md`: icon and comfort changes (DAP signs, lualine, winbar, gitsigns, illuminate), lockfile and test gotchas.

## Session log
- 2026-11-15: grill-me on a faster editor, then branch `perf/faster-boot-ty`: ShaDa capped and read after the first frame, blink.cmp off the first-file path (static capabilities), ty as default Python type server, `system/iterm2` removed (live iTerm2 prefs come from `~/iterm2-dotfiles`, dotfiles PR https://github.com/iklobato/dotfiles/pull/5). See `perf.md` and `../docs/decisions/2026-11-15-nvim-speed.md`.
- 2026-11-14 (2nd): UI icons package A plus vim-illuminate on branch `feat/ui-icons-comfort`; also added the missing `<leader>ch` deep test. See `ui.md`.
- 2026-11-14: added `lua/config/cloak.lua`, keymap `<leader>ch`, Telescope previewer guard, live_grep glob exclusions, 3 checks in `tests/features.lua`. See `cloak.md`; earlier history in `../docs/KNOWLEDGE.md`.
