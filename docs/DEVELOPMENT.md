# Development notes

How this config is laid out, how it loads, and how it is tested. For what it
does and its keys, see the [README](../README.md).

## Structure

```
init.lua                    # Main entry point
lua/
  core/                     # Core configuration
    options.lua
  plugins/                  # Modular plugin configurations
    init.lua                # Plugin loader
    core.lua                # Core plugins (treesitter, telescope, blink, conform)
    ui.lua                  # UI plugins (theme, bufferline, lualine, gitsigns, nvim-tree)
    lsp.lua                 # LSP plugins
    dap.lua                 # Debugging plugins
    tools.lua               # Utility plugins
  keymaps/                  # Categorized keymaps
    init.lua                # Keymap loader
    navigation.lua          # Window/tab navigation
    search.lua              # Telescope and search
    editing.lua             # Formatting and replace
    debug.lua               # Debugging keymaps
    git.lua                 # Git operations
    tools.lua               # Various tool keymaps
  lsp/                      # Enhanced LSP configuration
    init.lua                # Main LSP setup
    servers/                # Server-specific configurations
      python.lua            # pyright + ruff (native `ruff server`)
      lua.lua               # lua_ls
      typescript.lua        # ts_ls
      terraform.lua         # terraformls 0.11 compat shim
  autocmds/                 # Organized autocommands
    init.lua                # Autocmd loader
    filetypes.lua           # Filetype-specific settings
    session.lua             # Session management
    ui.lua                  # UI-related autocommands
  config/                   # Plugin setup bodies (see the rule below)
    blink.lua               # blink.cmp completion
    telescope.lua           # Telescope
    treesitter.lua          # Treesitter
    python_hl.lua           # Python-specific highlights
    conform.lua             # Formatters
    dap.lua                 # DAP adapters and launch configs
    dapui.lua               # DAP UI
    session.lua             # auto-session
colors/
  terminal-noir.lua         # Terminal Noir theme, same palette as the iTerm2 profile;
                            # vendored from nandomoreirame/terminalnoir, copy it again to update
queries/
  html_tags/injections.scm  # replaces the bundled query: <script> injects tsx
scripts/
  install.sh                # From-scratch installer (deps, config, dotfiles, plugins)
  brew-export.sh            # Dump installed Homebrew packages to system/Brewfile
  brew-import.sh            # Install everything from system/Brewfile
  mac_packs.sh, macos.sh    # macOS packages and defaults
  display.sh                # External monitor color profile (run by hand)
system/                     # Dotfiles and tool configs, detailed in system/README.md
  zshrc                     # Shell config (linked to ~/.zshrc)
  lazygit.yml               # Lazygit config (delta pager)
  Brewfile                  # Full machine package dump
tests/
  run.sh                    # luacheck + headless feature suite (64 checks)
  features.lua              # The checks: options, UI, LSP, DAP, keymaps, autocmds
  tmux_lib.sh               # Shared driver for the tmux suites (keys in, RPC out)
  e2e.sh                    # Real-nvim TUI smoke suite (24 checks)
  e2e-deep.sh               # Runs every deep area below, or only the ones named
  deep/                     # One script per area, each in its own nvim over a monorepo
  fixtures/monorepo.sh      # Builds that monorepo: django + react/ts + go, cached
  MANUAL.md                 # The handful of checks only eyes can make
docs/
  DEVELOPMENT.md            # This file
  demos/                    # The README GIFs and the VHS tapes that record them
```

### Where a plugin's config goes

One rule, so a plugin is never configured in two places at once:

- **`lua/plugins/*.lua`** holds the lazy spec (repo, lazy trigger, `opts`) and any
  `config`/`init` body up to about five lines.
- **`lua/config/<plugin>.lua`** holds anything longer, exposing `M.setup()`, and the
  spec just calls it.
- Autocmds that are not part of a plugin's own setup live in `lua/autocmds/`.

Ignoring this is how the `*.dbout` autocmd ended up registered twice.

## Plugins

- akinsho/bufferline.nvim (editor tabs)
- nvim-lualine/lualine.nvim (statusline)
- lewis6991/gitsigns.nvim (gutter change stripes)
- lazy.nvim
- nvim-lspconfig, mason.nvim, mason-lspconfig.nvim
- blink.cmp (completion, loads on the first buffer; see Performance)
- telescope.nvim (plenary.nvim, loads on demand)
- nvim-treesitter
  - nvim-treesitter-context (scope context)
  - nvim-treesitter-textobjects (af/if/ac/ic, main branch)
  - indent-blankline.nvim (indent guides)
  - nvim-puppeteer (Python f-string auto-conversion)
- nvim-tree (nvim-web-devicons)
- conform.nvim
- nvim-dap + nvim-dap-ui (nvim-nio) + mason-nvim-dap
- auto-session
- kulala.nvim (HTTP client, pure Lua, no luarocks)
- vim-dadbod + vim-dadbod-ui (SQL client, column/table completion via
  vim-dadbod-completion wired into blink.cmp in sql/mysql/plsql buffers)
- markdown-preview.nvim (clock-derived port in 8080-9079)
- Exafunction/windsurf.nvim (Codeium free tier, ghost text only, no cmp source)
- vim-maximizer
- f-person/git-blame.nvim (inline blame, 1s delay off the cursor path)

## LSP

- Servers ensured: pyright, ruff (native `ruff server`), lua_ls, ts_ls
- mason-lspconfig v2 auto-enables every installed server, so `automatic_enable`
  in `lua/lsp/init.lua` is an explicit allowlist. Add a server there to use it.
- `lua/lsp/servers/*.lua` must be required *before* `mason-lspconfig.setup()`:
  `vim.lsp.enable()` starts clients immediately, and a `vim.lsp.config()` call
  after that is ignored for the running client
- Loads deferred on the first buffer, then re-fires `nvim.lsp.enable` so the
  file opened from the command line also attaches
- Buffer-local LSP keymaps via `LspAttach`: `gd`, `gr`, `gi`, `K`,
  `<leader>rn`, `<leader>ca`. Global: `<leader>gd` (vsplit), `<leader>gr` (telescope)
- terraformls: default on_attach disabled on nvim 0.11 (uses a 0.12-only API)

## Treesitter

- Context showing function/class scope at top of window
- Textobjects: `af`/`if` (function), `ac`/`ic` (class)
- Incremental selection (built into nvim 0.12): `an` grows, `in` shrinks, in visual mode
- Indent guides (indent-blankline)
- Language parsers: lua, python, javascript, typescript, tsx, html, http, css,
  json, markdown, bash, vim, go, rust, ruby, toml, yaml, requirements,
  dockerfile, make, tmux
- `queries/html_tags/injections.scm` replaces the bundled query so a bare
  `<script>` injects tsx (JSX highlights in plain .html). It has to live under
  `html_tags/`, not `html/`: html_tags is a base lang for html, so a file under
  `queries/html/` can only add rules, never remove the javascript one

## Formatting

- `<leader>F` uses conform.nvim (no LSP fallback)
- Formatters: Python `ruff_format`, Lua `stylua`, C `clang_format`,
  JS/TS/JSON/CSS/HTML/YAML/Markdown `prettier` (reads `.prettierrc.json`)
- stylua, ruff and prettier come from mason; `clang_format` needs a system
  clang-format (mason has clangd only, and install.sh does not add it)
- A configured formatter whose binary is missing warns once per filetype
  ("Formatters unavailable for X file") and does nothing; run `:ConformInfo` if
  `<leader>F` seems to do nothing

## Performance

- Startup ~50ms: telescope and treesitter load on first use, not at boot.
  blink.cmp is the exception: `lua/lsp/init.lua` requires it so its plugin file
  registers LSP capabilities before any server starts, so it loads on the first
  buffer, not on InsertEnter
- Unused providers disabled (python3, ruby, perl, node)
- git-blame virtual text delayed 1s so it stays off the cursor path
- No lazyredraw (left at its default off; it causes stutter)

## Debugging in depth

### Async python

- Breakpoints inside `async def` stop like any other, and step over on an
  `await` stays in your code instead of walking into asyncio
- Launch file, Pytest file, Uvicorn app and the pytest keymaps run with
  `PYTHONASYNCIODEBUG=1`: a coroutine that was never awaited is reported with
  where it was created, and a callback that blocks the loop for over 100ms is
  logged
- An error raised in a task nobody awaits does not stop the session by default:
  asyncio keeps the exception, prints "Task exception was never retrieved" and
  the program exits 0. Press `<leader>be` and pick "user unhandled" to stop on
  the raise. It also stops on errors that a `try/except` around the `await`
  handles, which is why it is not the default
- The REPL lists the running tasks with
  `[t.get_name() for t in asyncio.all_tasks()]` and takes `await`, for example
  `await asyncio.sleep(0, result=42)`

### Adapters and configurations

- mason-nvim-dap ensures debugpy (python), delve (go) and js-debug-adapter
  (node, typescript, react). scripts/install.sh installs all three up front: if
  delve and js-debug-adapter are left for the first debug session, their
  install (delve is a go build) slows debugpy past its initialize timeout and
  that first python session fails
- Python: Launch file, Django runserver, Pytest file, Uvicorn app (asks for the
  ASGI app, default `main:app`, and runs without `--reload`). The adapter uses
  mason's debugpy when installed, otherwise the python of the active venv
- Go: Launch file, Launch package, Test package, Attach to process. delve gets a
  20s initialize timeout because it compiles the program before answering, and
  it is spawned in the file's directory so a monorepo root does not break the
  build with "cannot find main module"
- Node, typescript and react: Launch file, Attach to process, Attach to node
  port 9229, Launch Chrome on dev server (asks for the URL, default
  `http://localhost:5173`), Attach to Chrome port 9222. Launching a `.ts` file
  needs no ts-node or tsx: node 22.18+ strips the types itself
- "Attach to process" (go and node) first asks for part of the process name
  and lists only the matches; the full list is every process on the machine.
  For node it only works on a process started with `--inspect` (any port):
  on a plain node the adapter disconnects with no error. delve attaches to any
  go process you own
- Python has no attach configuration: start the program from a launch config
- The same js-debug-adapter serves node and chrome. React components only stop
  on the chrome configs; the node ones cannot reach browser code
- The chrome configs resolve `webRoot` to the nearest `package.json` above the
  open file, so source maps still line up when nvim was opened at a monorepo
  root instead of the frontend directory
- Known upstream noise: terminating a python session while it sits on a
  breakpoint makes debugpy SIGKILL the debuggee, and its adapter then exits 1,
  so nvim-dap warns. Letting the program finish, or terminating it while it
  runs, exits clean. delve and js-debug never do this

## Tests

```bash
./tests/run.sh       # luacheck, then 64 headless feature checks; nonzero on failure
./tests/e2e.sh       # real nvim TUI in tmux: real keystrokes, rendered screen,
                     # one full debug session; requires tmux
./tests/e2e-deep.sh  # the deep one: nearly every keymap and every debug feature
                     # across python, django, go, typescript and react in a browser
./tests/e2e-deep.sh lsp dap-python   # only those areas
./tests/deep/lsp.sh  # one area alone, with its full PASS/FAIL list
```

Areas: `ui` (statusline, motions, windows, tabs, explorer, buffers, save and
quit), `search` (telescope), `lsp` (python and typescript LSP keymaps,
diagnostics, formatting), `langs` (every other language server attaches, and
prettier/stylua format), `completion` (blink.cmp in insert mode and on the
command line), `session` (save on quit, restore on start, no explorer over a
restored session), `tools` (git, markdown, http client, database UI),
`dap-python`, `dap-go` and `dap-js`. Each one boots its own nvim, so a failure in one area
cannot leave state behind for the next, and each ends with the same health
checks (no errors in `:messages`, no hit-enter prompts, a clean quit).

`e2e-deep.sh` drives a realistic monorepo (django backend, react/typescript
frontend, go service, one git history, an `.http` file and a sqlite db) that
`tests/fixtures/monorepo.sh` builds under `~/.cache/nvim-e2e-deep`. Only the
first run pays for `npm install` and the backend venv. It starts real servers
and opens a real Chrome window while it runs, and takes several minutes.

What a script cannot assert (colours, glyphs, panel proportions, the rendered
markdown preview) is a short manual pass in `tests/MANUAL.md`.

## Demo GIFs

The README GIFs are recorded with [VHS](https://github.com/charmbracelet/vhs)
from the tapes in `docs/demos/`, against the same demo monorepo the tests use:

```bash
bash tests/fixtures/monorepo.sh /tmp/demo   # wiped on reboot, rebuild when missing
vhs docs/demos/04-lsp.tape                  # run from the repo root
```

- `settings.tape` holds the shared look (size, font, Terminal Noir colors).
- Each tape compiles `xterm-vhs.terminfo` and sets `TERM=xterm-vhs` first.
  Without it nvim sends truecolor as `38:2:r:g:b`, the xterm.js inside VHS
  reads that as `colorspace:r:g`, and the whole theme turns yellow.
- `09-database.tape` points `db_ui_save_location` at an empty folder so the
  database connections saved on your machine never end up in the GIF.
- Check a new GIF by its frames before committing it:
  `ffmpeg -i docs/demos/04-lsp.gif -vf fps=1/3 /tmp/frame-%02d.png`
