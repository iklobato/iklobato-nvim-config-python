# Neovim Config (Minimal)

A flat, minimal Neovim setup focused on Python/Django with LSP, DAP, Treesitter,
blink.cmp, and Conform. PyCharm-style UI: Darcula theme, editor tabs, statusline
and gutter change stripes.

## Structure

```
init.lua                    # Main entry point
lua/
  core/                     # Core configuration
    init.lua
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
    copilot.lua             # Copilot accept via Tab
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
  config/                   # Plugin-specific configurations
    blink.lua               # blink.cmp completion
    telescope.lua           # Telescope
    treesitter.lua          # Treesitter + rainbow highlights
    python_hl.lua           # Python-specific highlights
    conform.lua             # Formatters
    dap.lua                 # DAP
    dapui.lua               # DAP UI
  utils/                    # Utility functions
    init.lua                # Utility loader
    mappings.lua            # Keymap helpers
    plugin_loader.lua       # Plugin loading utilities
    diagnostics.lua         # Diagnostic utilities
tests/
  run.sh                    # Headless feature suite (42 checks)
  features.lua              # The checks: options, UI, LSP, DAP, keymaps, autocmds
  e2e.sh                    # Real-nvim TUI suite driven via tmux (24 checks)
```

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
  - indent-blankline.nvim (indent guides)
  - nvim-puppeteer (Python f-string auto-conversion)
- nvim-tree (nvim-web-devicons)
- conform.nvim
- nvim-dap + nvim-dap-ui (nvim-nio) + mason-nvim-dap
- auto-session
- rest.nvim (HTTP client)
- vim-dadbod + vim-dadbod-ui (SQL client)
- markdown-preview.nvim (random free port)
- github/copilot.vim (bundled language server, no npx)
- vim-maximizer
- f-person/git-blame.nvim (inline blame, 1s delay off the cursor path)

## LSP

- Servers: pyright, ruff (native `ruff server`), lua_ls, ts_ls
- Loads deferred on the first buffer, then re-fires `nvim.lsp.enable` so the
  file opened from the command line also attaches
- Buffer-local LSP keymaps: `gd`, `gr`, `<leader>gr`, `gi`, `K`, `<leader>rn`, `<leader>ca`
- terraformls: default on_attach disabled on nvim 0.11 (uses a 0.12-only API)

## Treesitter

- Enhanced highlighting with `use_languagetree = true`
- Rainbow brackets for nested structures
- Context showing function/class scope at top of window
- Indent guides (indent-blankline)
- Language parsers: lua, python, javascript, typescript, tsx, html, css, json, markdown, bash, vim, go, rust, ruby, toml, yaml

## Keymaps

- Search: `<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader>fo`
- File ops: `<leader>ww`, `<leader>wq`, `<leader>qq`
- Diagnostics: `<leader>e`, `<leader>E`, `[d`, `]d`
- Git: `<leader>gb`
- File explorer: `<leader>ee` (toggle), `<leader>ef` (reveal)
- Windows: `<leader>sv`, `<leader>sh`, `<leader>se`, `<leader>sm` (maximize)
- Tabs: `<leader>to`, `<leader>tn`
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
- Formatters: Python `ruff_format`, Lua `stylua`

## Performance

- Startup ~42ms: telescope, blink and treesitter load on first use, not at boot
- Unused providers disabled (python3, ruby, perl, node)
- git-blame virtual text delayed 1s so it stays off the cursor path
- No lazyredraw (Neovim marks it unsupported; it causes stutter)

## Tests

```bash
./tests/run.sh    # headless: 42 feature checks, exits nonzero on failure
./tests/e2e.sh    # real nvim TUI in tmux: real keystrokes, rendered screen,
                  # full debug session; requires tmux
```

## Install

```bash
git clone https://github.com/iklobato/iklobato-nvim-config-python.git ~/.config/nvim
```

Open Neovim and let lazy.nvim install plugins.

## Requirements

- Neovim 0.11+
- Python 3 (for LSP and DAP)
- Node.js and ripgrep (for Telescope and LSP servers)
- tmux (only for tests/e2e.sh)
