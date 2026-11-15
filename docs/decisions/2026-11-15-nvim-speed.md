# Faster editor: decision tree (grill-me, 2026-11-15)

Snapshot: `main` @ `fe40ecc` (2026-11-15). Every number below was measured in this session on this machine unless marked "not measured".

## Baseline (measured)

- Machine: Intel i9-9980HK (16 threads, x86_64), 64 GB RAM (84% free), Intel UHD 630 + AMD Radeon Pro 5500M, macOS 14.6.1.
- Editor: NVIM v0.12.5, LuaJIT 2.1, 41 plugins in `lazy-lock.json`.
- Boot (`--startuptime`, 3 runs): 139.7 / 138.0 / 135.8 ms. `nvim --clean`: 0.127 s total vs 0.343 s with config (`time`).
- Biggest boot costs: `require('plugins')` 71 ms, `reading ShaDa` 14.5 ms, `require('keymaps')` 11.8 ms (`keymaps.tools` 5.4 ms), `lazy.view.commands` 4.7 ms, `matchit.vim` 4.5 ms.
- ShaDa: `main.shada` 185 KB (cmd 1044, search 2294, input 767 history entries; 'history'=10000). Trimmed to `:200,/100,@50` = 25 KB; read time 11.0-14.1 ms -> 6.6-8.5 ms (5 runs each, copies only).
- Python LSP: pyright (Node) + ruff. blink.cmp already `prefer_rust`. Picker: Telescope + fzf-native.
- Terminal: iTerm2 3.7.4 (3.7.7 available). Live prefs: `useMetal True`, `preferIntegratedGPU True`, `disableMetalWhenUnplugged False`, `MaximumFrameRate 60`, default profile Terminal Noir (no ligatures, no transparency, no blur).

## Decisions

| # | Decision | Answer | Why | Depends on |
|---|---|---|---|---|
| 1 | What feels slow | Boot, typing/scrolling, LSP/search/big files | user report | - |
| 2 | Direction | Stay on Neovim and optimize | no "Neovim in Rust" exists; Helix/Zed lose the config | - |
| 3 | How much config may be lost | Nothing | user | 2 |
| 4 | Boot target | < 80 ms, median of 5 `--startuptime` runs | low-risk cuts cover it | 1 |
| 5 | ShaDa: stale `main.shada.tmp.a` (234 KB, 2026-11-05) | Delete | leftover temp file | 4 |
| 6 | ShaDa history limits | Add `:200,/100` (and `@50`) to `shada` | measured 11 -> 7 ms | 4 |
| 7 | ShaDa read timing | Read after the first frame | removes the remaining ~7 ms from boot | 4 |
| 8 | Python LSP | ty (Astral, Rust, 0.0.104) is the default; pyright behind a toggle | speed; ty is beta, so keep a way back | 3 |
| 9 | ty install | Mason, add `ty` to `MASON_TOOLS` in `scripts/install.sh` | same path as pyright/ruff; registry has `ty` | 8 |
| 10 | Picker | Keep Telescope, tune only | zero keymap churn | 3 |
| 11 | Terminal | Stay on iTerm2 and tune it | already GPU + integrated GPU; public latency data conflicts; dual-GPU risk with others not ruled out | 1, 3 |
| 12 | tmux | Not used | user | - |
| 13 | iTerm2 version | Update 3.7.4 -> 3.7.7 | fixes; auto-update exists | 11 |
| 14 | iTerm2 config source of truth | `~/iterm2-dotfiles` (repo `iklobato/dotfiles`) | verified: live `PrefsCustomFolder` and `Default Bookmark Guid` 7E1A... come from there | 11 |
| 15 | nvim repo `system/iterm2` + `install_iterm` | Remove from this repo | stale copy (2026-07-21, font 11); rerunning `install.sh` would repoint iTerm2 to it | 14 |
| 16 | Dynamic profile | Repo json becomes the source; the installed file becomes a symlink, after merging what only the installed copy has; backup first; user checks the look | installed file has `Default` (6A3D) + `Terminal Noir` (7E1A, in use, parent `Default`); repo copy has only Terminal Noir and differs | 14 |
| 17 | iTerm2 features to turn off | Python API server, dim inactive split, visual bell, paste history, AI features, blinking text, notifications (`BM Growl`) | unused or risky (paste history keeps pasted secrets on disk); speed gain not measured | 11 |
| 18 | Typing/scroll cost per plugin | Measure and show in chat only; change nothing | user wants numbers first | 1, 3 |
| 19 | Delivery | One PR in the nvim repo; iTerm2 tuning in a separate PR in the dotfiles repo | user; the plist lives in dotfiles | 14 |
| 20 | Done for the nvim PR | Boot < 80 ms (median of 5), `tests/run.sh` and e2e pass, ty works on a real `.py` (hover, definition, diagnostics; toggle back to pyright works) | user | 4, 8 |

## Assumptions (cheap to change)

- Toggle name for the Python LSP: env var `NVIM_PY_LSP=pyright` switches back from ty.
- Telescope tuning stays inside `lua/config/telescope.lua` (ignore patterns, rg/fd commands).

## Open risks

- ty is 0.0.x beta: features may be missing vs pyright (some code actions, some inference).
- Reading ShaDa after the first frame: auto-session, `:oldfiles` and marks must still work; covered by tests only if a check exists.
- The dotfiles repo has 3 uncommitted user changes (plist, `knowledge/README.md`, aliases): its PR waits for the user to commit them.
- Turning off iTerm2 notifications drops the "command finished" alert.
- Ghostty/kitty never measured on this machine; the terminal choice rests on the current iTerm2 setup, not on a benchmark.

## Left undecided

- Other stale copies in `system/` (for example `zshrc`, `tmux.conf`) while `~/.zshrc` links to `~/iterm2-dotfiles/zsh/zshrc`: not discussed.
- Which plugins to change after the per-keystroke measurement: decided later, after the numbers.
