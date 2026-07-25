# Neovim Config (Minimal)

A flat, minimal Neovim setup focused on Python/Django with LSP, DAP, Treesitter,
blink.cmp, and Conform. PyCharm-style UI: Darcula theme, editor tabs, statusline
and gutter change stripes.

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
    dap.lua                 # DAP
    dapui.lua               # DAP UI
queries/
  html_tags/injections.scm  # replaces the bundled query: <script> injects tsx
scripts/
  install.sh                # From-scratch installer (deps, config, dotfiles, plugins)
  brew-export.sh            # Dump installed Homebrew packages to system/Brewfile
  brew-import.sh            # Install everything from system/Brewfile
system/
  zshrc                     # Shell config (linked to ~/.zshrc)
  Brewfile                  # Full machine package dump
  lazygit.yml               # Lazygit config (delta pager)
tests/
  run.sh                    # luacheck + headless feature suite (43 checks)
  features.lua              # The checks: options, UI, LSP, DAP, keymaps, autocmds
  e2e.sh                    # Real-nvim TUI suite driven via tmux (24 checks)
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
- blink.cmp (completion, loads on InsertEnter/CmdlineEnter)
- telescope.nvim (plenary.nvim, loads on demand)
- nvim-treesitter
  - nvim-treesitter-context (scope context)
  - nvim-treesitter-textobjects (af/if/ac/ic, master branch)
  - indent-blankline.nvim (indent guides)
  - nvim-puppeteer (Python f-string auto-conversion)
- nvim-tree (nvim-web-devicons)
- conform.nvim
- nvim-dap + nvim-dap-ui (nvim-nio) + mason-nvim-dap
- auto-session
- kulala.nvim (HTTP client, pure Lua, no luarocks)
- vim-dadbod + vim-dadbod-ui (SQL client)
- markdown-preview.nvim (random free port)
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
- Incremental selection: `gnn`, `grn`, `grc`, `grm`
- Indent guides (indent-blankline)
- Language parsers: lua, python, javascript, typescript, tsx, html, http, css,
  json, markdown, bash, vim, go, rust, ruby, toml, yaml, requirements,
  dockerfile, make, tmux
- `queries/html_tags/injections.scm` replaces the bundled query so a bare
  `<script>` injects tsx (JSX highlights in plain .html). It has to live under
  `html_tags/`, not `html/`: html_tags is a base lang for html, so a file under
  `queries/html/` can only add rules, never remove the javascript one

## Keymaps

- Search: `<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader>fo`
- File ops: `<leader>ww`, `<leader>wq`, `<leader>qq`
- Diagnostics: `<leader>e`, `<leader>E`, `[d`, `]d`
- Git: `<leader>gb`
- File explorer: `<leader>ee` (toggle), `<leader>ef` (reveal)
- Windows: `<leader>sv`, `<leader>sh`, `<leader>se`, `<leader>sm` (maximize)
- Tabs: `<leader>to`, `<leader>tn`, `<leader>tp`
- Buffers: `<leader>bn`, `<leader>bp`, `<leader>bd`. Not on `<Tab>`: in a
  terminal that is the same byte as `<C-i>`, and it would kill jumplist-forward
- Replace: `<leader>S`
- Format: `<leader>f` (normal/visual)
- Markdown preview: `<leader>mp` / `<leader>mP`
- Breakpoints: `<leader>bb`, `<leader>bc`, `<leader>bl`, `<leader>br`, `<leader>ba` (quickfix list)
- Debugging: `<leader>dc`, `<leader>dj`, `<leader>dk`, `<leader>do`, `<leader>dl`, `<leader>dt`, `<leader>dd`, `<leader>du`
- Pytest: `<leader>dp` (picker from LSP symbols), `<leader>df` (function under cursor, class-aware)

## Debugging

- Python configs: Launch file, Django runserver, Pytest file
- Adapter uses mason's debugpy when installed, otherwise the active venv python
- dap-ui and mason-nvim-dap load together with nvim-dap; the UI opens and
  closes automatically with the session
- DAP UI layout: left (scopes/watches/breakpoints), right (repl/console),
  sizes scale with the terminal width

## Sessions

- Auto-restores sessions on startup (auto-session defaults)
- NvimTree opens only if no session was restored

## Formatting

- `<leader>f` uses conform.nvim (no LSP fallback)
- Formatters: Python `ruff_format`, Lua `stylua`, C `clang_format`,
  JS/TS/JSON/CSS/HTML/YAML/Markdown `prettier` (reads `.prettierrc.json`)
- All of them come from mason; a formatter that is not installed is a silent
  no-op, so check with `:ConformInfo` if `<leader>f` seems to do nothing

## Performance

- Startup ~43ms: telescope and treesitter load on first use, not at boot.
  blink.cmp is the exception: `lua/lsp/init.lua` requires it so its plugin file
  registers LSP capabilities before any server starts, so it loads on the first
  buffer, not on InsertEnter
- Unused providers disabled (python3, ruby, perl, node)
- git-blame virtual text delayed 1s so it stays off the cursor path
- No lazyredraw (Neovim marks it unsupported; it causes stutter)

## Tests

```bash
./tests/run.sh    # luacheck, then 43 headless feature checks; nonzero on failure
./tests/e2e.sh    # real nvim TUI in tmux: real keystrokes, rendered screen,
                  # full debug session; requires tmux
```

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

- **Dependencies**: Neovim 0.11+, git, Node 22+, ripgrep, python3, git-delta
  (lazygit pager), Meslo LG Nerd Font
- **Config**: this repo at `~/.config/nvim`
- **Dotfiles**: `system/zshrc` → `~/.zshrc` and `system/lazygit.yml` → the
  platform lazygit path, plus oh-my-zsh and the zsh-syntax-highlighting plugin
  the zshrc expects
- **Plugins**: `Lazy! sync` headless, then mason installs pyright, ruff, lua_ls,
  ts_ls, stylua and debugpy

`system/Brewfile` is *not* installed by the script: it's a full machine dump.
Use `./scripts/brew-import.sh` if you want it.

After install, set your terminal font to "MesloLGS Nerd Font" so icons render.

## Requirements

- macOS or Ubuntu/Debian (other systems: install deps manually, then run the script)
- Neovim 0.11+
- Python 3 (for LSP and DAP)
- Node.js 22+ and ripgrep (for Telescope, LSP servers, Copilot)
- tmux (only for tests/e2e.sh)
