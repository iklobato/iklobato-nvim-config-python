# nvim config: boot and LSP speed

Snapshot: `perf/faster-boot-ty` off `main` @ `fe40ecc` (2026-11-15). Measured on an Intel i9-9980HK MacBook Pro (64 GB) with load average 8-12 from other work, so single runs swing by 2x; only the interleaved A/B medians below are worth comparing. Decision tree: `../docs/decisions/2026-11-15-nvim-speed.md`.

## How to measure (and not destroy your history)

- Never benchmark against the real ShaDa: every run rewrites it on exit. Copy it and pass `-i <copy>`, fresh copy per run.
- A/B against `main` without stashing: `git worktree add --detach <dir> main`, then `XDG_CONFIG_HOME=<xdg>` where `<xdg>/nvim` links to the worktree. Plugins (data dir) stay shared. Interleave base/new runs so machine load hits both equally; drop the first run (cold `vim.loader` cache).
- `wshada!` (with bang) writes only what is in memory and DROPS file marks of unloaded files, so `v:oldfiles` comes back empty. A normal exit merges and keeps them. Test ShaDa limits with a normal exit, not `wshada!`.

## Results (median of 7, interleaved, 2026-11-15)

```
empty   median base=50.131 new=43.099      (ms to "NVIM STARTED")
py file median base=247.311 new=220.476
```

Earlier single runs in the same session read 102 ms (empty) and 456 ms (file) for `main`: same config, heavier machine load. Use the A/B numbers.

## What was cut

- ShaDa: `'history'` is 10000, so the file had grown to 185 KB (cmd 1044, search 2294, input 767 entries) and took ~11 ms to read. `:200,/100,@50` makes it 53 KB / ~5.5 ms, and the read now happens in `VimEnter` + `vim.schedule` (after the first frame). `shada` is empty during startup on purpose: `nvim -c qa` before VimEnter writes nothing, which is fine.
- `lua/lsp/init.lua` no longer `require("blink.cmp")` on the first file. blink setup spawns `git describe`, `git rev-parse` and `shasum` to check its prebuilt Rust binary on every load (`fuzzy/download/init.lua`), ~25-80 ms depending on load. Its capabilities are a static table; `tests/features.lua` compares it with `get_lsp_capabilities()` so a blink upgrade that changes them fails the suite. blink itself now loads on `VeryLazy`.
- `<leader>gf` was mapped to `vim.diagnostic.open_float` directly, which loads `vim.diagnostic` (~3 ms) on every boot. Wrapped in a function.
- Not cut: `lazy.view.commands` (~5 ms) is lazy.nvim registering `:Lazy` inside `setup()`; `matchit` (~3.5 ms) is kept on purpose for `%`; treesitter and auto-session stay `lazy = false` (moving them risks the first frame and session restore).

## Python type server: ty

- ty 0.0.104 (Mason) is the default, pyright with `NVIM_PY_LSP=pyright`. Exactly one is enabled; a missing binary falls back to the other.
- Probe on `monorepo/backend/core/views.py` (deep fixture), cold start: ty initialize 26-40 ms vs pyright 401-405 ms; first hover 165 ms vs 1511 ms; definition 1 ms vs 43 ms. Both report the same unused-arg and type-assignment diagnostics.
- No venv in the project: pyright falls back to the python on PATH, ty only to its bundled stdlib, so every third-party import was unresolved (arena-ui-backend: 4 errors vs pyright 1). `lua/lsp/servers/python.lua` now passes ty `initializationOptions.configuration.environment.python` = the pyenv prefix (`.python-version` up the tree, else `~/.pyenv/version`) when there is no `VIRTUAL_ENV` and no `.venv`; after that both report the same single `sqlmodel` error. Read from disk on purpose: asking the pyenv shim for `sys.prefix` takes ~270 ms, and ty rejects the shim path itself.
- ty is still 0.0.x: pyright-specific settings (`diagnosticMode`, `typeCheckingMode`) do not apply to it.

## Telescope

No measured slowness, so nothing changed. `rg --files` (no `fd` installed) already honours `.gitignore`; `file_ignore_patterns` is a per-entry Lua filter and was not measured.

## Deep lsp suite: two races fixed (2026-11-15)

`tests/deep/lsp.sh` failed 6 of 9 runs on `[d jumps back to a diagnostic` (with ty and with `NVIM_PY_LSP=pyright` exported, though tmux may not pass that env to the session, so the pyright runs are not proven to be pyright). Cause: after `:bd!` + `:e legacy.py`, ruff's diagnostics arrive 44-92 ms later (headless probe, 5 reopens per server, only `Ruff` diagnostics on lines 1-2 with either type server), and the test sent `[d` before that. Now it waits for `#vim.diagnostic.get(0) > 0`. Once in those 9 runs `<leader>rn` typed the new name before the rename prompt opened (prepareRename round trip); now it waits for `mode() == "c"`. After both: 7/7 green.
