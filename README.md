# Neovim Config (Minimal)

A flat, minimal Neovim setup focused on Python/Django with LSP, DAP, Treesitter,
blink.cmp, and Conform. PyCharm-style UI: Darcula theme, editor tabs, statusline
and gutter change stripes. Debugging also covers go, node, typescript and react.

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
  run.sh                    # luacheck + headless feature suite (62 checks)
  features.lua              # The checks: options, UI, LSP, DAP, keymaps, autocmds
  tmux_lib.sh               # Shared driver for the tmux suites (keys in, RPC out)
  e2e.sh                    # Real-nvim TUI smoke suite (24 checks)
  e2e-deep.sh               # Nearly every keymap and every debug feature, over a monorepo
  fixtures/monorepo.sh      # Builds that monorepo: django + react/ts + go, cached
  MANUAL.md                 # The handful of checks only eyes can make
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

- xiantang/darcula-dark.nvim (PyCharm Darcula theme)
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
- github/copilot.vim (bundled language server, no npx)
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

## Keymaps

Leader is `<Space>`. Every map carries a `desc`, so `:Telescope keymaps` lists
them with their descriptions. Debug keymaps have their own section further down.

### Motions

| Key | Does | Note |
|---|---|---|
| `H` / `L` | go to line start / line end | `^` and `$` without the symbol keys |
| `W` / `B` | word back / word forward | deliberately swapped from vim's defaults, normal mode only (operators and visual still use the builtins) |
| `<leader>j` / `<leader>k` | down / up one *screen* line | `gj`/`gk`, moves inside a wrapped line |

### Files, windows, tabs, buffers

| Key | Does | Note |
|---|---|---|
| `<leader>ww` | save | |
| `<leader>wq` | save and quit | |
| `<leader>qq` | quit and throw away changes | `:q!` |
| `<leader>ee` | file explorer on/off | nvim-tree |
| `<leader>ef` | reveal the current file in the explorer | |
| `<leader>sv` / `<leader>sh` | split vertical / horizontal | |
| `<leader>se` | equalize splits, in every tab | |
| `<leader>sm` | maximize the split, press again to restore | vim-maximizer |
| `<leader>to` / `<leader>tn` / `<leader>tp` | new / next / previous tab | |
| `<leader>bn` / `<leader>bp` / `<leader>bd` | next / previous / close buffer | the tabs bufferline draws on top. Not on `<Tab>`: in a terminal that is the same byte as `<C-i>`, and it would kill jumplist-forward |

### Search

| Key | Does | Note |
|---|---|---|
| `<leader>ff` | find files | includes gitignored files (`no_ignore`) |
| `<leader>fg` | grep the whole project as you type | e.g. type `def index` to land on the Django view |
| `<leader>fb` | pick an open buffer | |
| `<leader>fo` | symbols of the current file | name column width follows the window width |

### LSP

| Key | Does | Note |
|---|---|---|
| `gd` / `gr` / `gi` / `K` | definition / references / implementations / hover | buffer-local, appear only after a server attaches |
| `<leader>rn` / `<leader>ca` | rename / code action | buffer-local |
| `<leader>gd` | definition in a vertical split | splits only after a result comes back, so a miss leaves no empty window |
| `<leader>gr` | references in telescope | |

### Diagnostics

| Key | Does | Note |
|---|---|---|
| `<leader>e` | float with the diagnostic under the cursor | |
| `<leader>E` | the same float, already focused | select and yank the message directly, `q`/`<Esc>` closes it |
| `[d` / `]d` | previous / next diagnostic | takes a count, `3]d` jumps three |
| `<leader>gp` / `<leader>gn` | same as `[d` / `]d`, count included | |

### Editing

| Key | Does | Note |
|---|---|---|
| `<leader>f` | format the buffer (normal) or the selection (visual) | conform.nvim, no LSP fallback |
| `<leader>S` | replace the word under the cursor everywhere in the file | fills `:%s/\<word\>/word/gI` with the old word prefilled as the replacement and the cursor after it: clear it with `<C-w>`, type the new text, press Enter |
| `<leader>S` (visual) | same, using the selection | |

### Git and tools

| Key | Does | Note |
|---|---|---|
| `<leader>gb` | inline git blame on/off | |
| `<leader>mp` / `<leader>mP` | markdown preview start / stop | |
| `<leader>rr` | run the HTTP request under the cursor | kulala, in `.http` files |
| `<leader>db` | database UI on/off | dadbod-ui. Queries run with its own buffer-local `<leader>S` |

## Debugging

Works in python, go, javascript, typescript and both react filetypes. Any other
filetype has no configuration, and `<leader>dc` says so instead of starting.

### Breakpoint keymaps

| Key | Does | Example |
|---|---|---|
| `<leader>bb` | breakpoint on the current line, press again to remove | |
| `<leader>bc` | breakpoint that only stops when a condition holds | asks for it, answer `i == 3` to stop on the 4th pass of a loop |
| `<leader>bl` | logpoint: prints instead of stopping | asks for the message, answer `double {value}` and every call prints in the REPL with `value` filled in |
| `<leader>ba` | put every breakpoint in the quickfix window | `:cclose` to close it again |
| `<leader>br` | delete every breakpoint | |

### Session keymaps

| Key | Does | Note |
|---|---|---|
| `<leader>dc` | start, or continue when stopped | the first press shows the numbered config menu for the filetype |
| `<leader>dj` | step over | |
| `<leader>dk` | step into | steps into the function being called on the current line |
| `<leader>do` | step out | back to the caller |
| `<leader>dl` | run the last config again | no menu. `${file}` is re-expanded, so it follows the buffer you are on, not the one the last run used |
| `<leader>dt` | terminate the session | UI closes with it |
| `<leader>dd` | disconnect and close the UI | |
| `<leader>du` | show / hide the UI | the session keeps running |

Python only:

| Key | Does | Note |
|---|---|---|
| `<leader>df` | debug the pytest test under the cursor | reads LSP symbols, so `TestClass::test_method` is resolved for a method |
| `<leader>dp` | picker with every test in the file | plus a "Manual" entry to type any pytest target |

Commands, once the plugin has loaded: `:DapEval` (evaluate expressions in a
scratch window), `:DapToggleRepl`, `:DapPause`, `:DapRestartFrame`,
`:DapShowLog`.

### A full run, start to finish

With a file that has a `double()` helper called inside a loop:

1. `<leader>bc` on the loop line, answer `i == 3`
2. `<leader>bl` on the first line of `double`, answer `double {value}`
3. `<leader>ba` to confirm both are registered, `:cclose`
4. `<leader>dc`, pick `1` (Launch file); the UI opens and execution stops on the
   loop only when `i` is 3
5. read `i` and `total` in the Scopes panel
6. `<leader>dk` steps into `double`, `<leader>do` comes back, `<leader>dj` moves
   one line
7. `<leader>dc` runs to the end; the logpoint lines are waiting in the REPL
8. `<leader>dt` ends it, `<leader>dl` runs the same config again without asking

### The UI

Left column: scopes, watches, breakpoints. Right column: REPL and console. Both
scale with the terminal width. It opens and closes with the session.

Inside any panel: `<CR>` expands, `e` edits a value, `d` removes an entry, `r`
sends the entry to the REPL, `o` opens, `t` toggles. The watches panel is a
prompt buffer: press `i` and type an expression such as `total * 10`. The REPL
takes expressions the same way.

### Adapters and configurations

- mason-nvim-dap ensures debugpy (python), delve (go) and js-debug-adapter
  (node, typescript, react). debugpy is installed up front by scripts/install.sh;
  delve and js-debug-adapter install on the first debug session
- Python: Launch file, Django runserver, Pytest file. The adapter uses mason's
  debugpy when installed, otherwise the python of the active venv
- Go: Launch file, Launch package, Test package, Attach to process. delve gets a
  20s initialize timeout because it compiles the program before answering, and
  it is spawned in the file's directory so a monorepo root does not break the
  build with "cannot find main module"
- Node, typescript and react: Launch file, Attach to process, Attach to node
  port 9229, Launch Chrome on dev server (asks for the URL, default
  `http://localhost:5173`), Attach to Chrome port 9222. Launching a `.ts` file
  needs no ts-node or tsx: node 22.18+ strips the types itself
- The same js-debug-adapter serves node and chrome. React components only stop
  on the chrome configs; the node ones cannot reach browser code
- The chrome configs resolve `webRoot` to the nearest `package.json` above the
  open file, so source maps still line up when nvim was opened at a monorepo
  root instead of the frontend directory
- Known upstream noise: terminating a python session while it sits on a
  breakpoint makes debugpy SIGKILL the debuggee, and its adapter then exits 1,
  so nvim-dap warns. Letting the program finish, or terminating it while it
  runs, exits clean. delve and js-debug never do this

## Sessions

- Auto-restores sessions on startup (auto-session defaults)
- NvimTree opens only if no session was restored

## Formatting

- `<leader>f` uses conform.nvim (no LSP fallback)
- Formatters: Python `ruff_format`, Lua `stylua`, C `clang_format`,
  JS/TS/JSON/CSS/HTML/YAML/Markdown `prettier` (reads `.prettierrc.json`)
- stylua, ruff and prettier come from mason; `clang_format` needs a system
  clang-format (mason has clangd only, and install.sh does not add it)
- A configured formatter whose binary is missing warns once per filetype
  ("Formatters unavailable for X file") and does nothing; run `:ConformInfo` if
  `<leader>f` seems to do nothing

## Performance

- Startup ~50ms: telescope and treesitter load on first use, not at boot.
  blink.cmp is the exception: `lua/lsp/init.lua` requires it so its plugin file
  registers LSP capabilities before any server starts, so it loads on the first
  buffer, not on InsertEnter
- Unused providers disabled (python3, ruby, perl, node)
- git-blame virtual text delayed 1s so it stays off the cursor path
- No lazyredraw (left at its default off; it causes stutter)

## Tests

```bash
./tests/run.sh       # luacheck, then 62 headless feature checks; nonzero on failure
./tests/e2e.sh       # real nvim TUI in tmux: real keystrokes, rendered screen,
                     # one full debug session; requires tmux
./tests/e2e-deep.sh  # the deep one: nearly every keymap and every debug feature
                     # across python, django, go, typescript and react in a browser
```

`e2e-deep.sh` drives a realistic monorepo (django backend, react/typescript
frontend, go service, one git history, an `.http` file and a sqlite db) that
`tests/fixtures/monorepo.sh` builds under `~/.cache/nvim-e2e-deep`. Only the
first run pays for `npm install` and the backend venv. It starts real servers
and opens a real Chrome window while it runs, and takes several minutes.

What a script cannot assert (colours, glyphs, panel proportions, the rendered
markdown preview) is a short manual pass in `tests/MANUAL.md`.

## Install

From scratch on a new machine (macOS or Ubuntu/Debian):

```bash
curl -fsSL https://raw.githubusercontent.com/iklobato/iklobato-nvim-config-python/main/scripts/install.sh | bash
```

Or from a local checkout:

```bash
git clone https://github.com/iklobato/iklobato-nvim-config-python.git ~/.config/nvim
~/.config/nvim/scripts/install.sh
```

Pass `--no-dotfiles` to install Neovim only and leave `~/.zshrc` and lazygit
untouched. Anything it replaces (`~/.config/nvim`, `~/.zshrc`, lazygit config)
is moved to a timestamped `.bak_<date>` first.

What it sets up:

- **Dependencies**: Neovim 0.12+, git, Node 22+, ripgrep, python3, git-delta
  (lazygit pager), Meslo LG Nerd Font
- **Config**: this repo at `~/.config/nvim`
- **Dotfiles**: `system/zshrc` → `~/.zshrc` and `system/lazygit.yml` → the
  platform lazygit path, plus oh-my-zsh and the zsh-syntax-highlighting plugin
  the zshrc expects
- **Plugins**: `Lazy! sync` headless, then mason installs pyright, ruff, lua_ls,
  ts_ls, stylua and debugpy. delve and js-debug-adapter are not installed here:
  mason-nvim-dap pulls them the first time you open a debug session

`system/Brewfile` is *not* installed by the script: it's a full machine dump.
Use `./scripts/brew-import.sh` if you want it.

After install, set your terminal font to "MesloLGS Nerd Font" so icons render.

## Requirements

- macOS or Ubuntu/Debian (other systems: install deps manually, then run the script)
- Neovim 0.12+ (nvim-treesitter main branch), tree-sitter CLI 0.26.1+, a C compiler
- Python 3 (for LSP and DAP)
- Node.js 22.18+ and ripgrep (for Telescope, LSP servers, Copilot, and the
  node/typescript debugger)
- Go (only to debug Go: mason builds delve with the local toolchain)
- tmux (for tests/e2e.sh and tests/e2e-deep.sh; e2e-deep also needs npm, curl,
  go and a Chrome for its react phase)
