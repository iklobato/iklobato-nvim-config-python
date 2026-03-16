# Neovim Config (Minimal)

A flat, minimal Neovim setup focused on Python/Django with LSP, DAP, Treesitter,
blink.cmp, and Conform.

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
    ui.lua                  # UI plugins (theme, nvim-tree)
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
      python.lua            # pyright + ruff
      lua.lua               # lua_ls
      typescript.lua        # ts_ls
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
```

## Plugins

- rebelot/kanagawa.nvim (theme, wave)
- lazy.nvim
- nvim-lspconfig, mason.nvim, mason-lspconfig.nvim
- blink.cmp (completion)
- telescope.nvim (plenary.nvim)
- nvim-treesitter
  - nvim-treesitter-context (scope context)
  - indent-blankline.nvim (indent guides)
  - nvim-puppeteer (Python f-string auto-conversion)
- nvim-tree (nvim-web-devicons)
- conform.nvim
- nvim-dap + nvim-dap-ui (nvim-nio)
- auto-session
- rest.nvim (HTTP client)
- vim-dadbod + vim-dadbod-ui (SQL client)
- markdown-preview.nvim
- github/copilot.vim
- vim-maximizer

## LSP

- Servers: pyright, ruff, lua_ls, ts_ls
- Buffer-local LSP keymaps: `gd`, `gr`, `<leader>gr`, `gi`, `K`, `<leader>rn`, `<leader>ca`

## Treesitter

- Enhanced highlighting with `use_languagetree = true`
- Rainbow brackets for nested structures
- Context showing function/class scope at top of window
- Indent guides (indent-blankline)
- Language parsers: lua, python, javascript, typescript, tsx, html, css, json, markdown, bash, vim, go, rust, ruby, toml, yaml

## Keymaps

- Search: `<leader>ff`, `<leader>fg`, `<leader>fb`
- File ops: `<leader>ww`, `<leader>wq`, `<leader>qq`
- Diagnostics: `<leader>e`, `<leader>E`, `[d`, `]d`
- Git: `<leader>gb`
- File explorer: `<leader>ef`
- Windows: `<leader>sv`, `<leader>sh`, `<leader>se`
- Tabs: `<leader>to`, `<leader>tn`
- Replace: `<leader>S`
- Format: `<leader>f` (normal/visual)
- Breakpoints: `<leader>bb`, `<leader>bc`, `<leader>bl`, `<leader>br`, `<leader>ba`
- Debugging: `<leader>dc`, `<leader>dj`, `<leader>dk`, `<leader>do`, `<leader>dl`, `<leader>dt`, `<leader>dd`, `<leader>du`

## Debugging

- Python configs: Launch file, Django runserver, Pytest file
- Requires `debugpy` in your active Python environment
- DAP UI layout: left 20% (scopes/stacks/watches/breakpoints), right 30% (repl/console)

## Sessions

- Auto-restores sessions on startup (auto-session defaults)
- NvimTree opens only if no session was restored

## Formatting

- `<leader>f` uses conform.nvim (no LSP fallback)
- Formatters: Python `ruff_format`, Lua `stylua`

## Install

```bash
git clone https://github.com/iklobato/iklobato-nvim-config-python.git ~/.config/nvim
```

Open Neovim and let lazy.nvim install plugins.

## Requirements

- Neovim 0.11+
- Python 3 (for LSP and DAP)
- Node.js and ripgrep (for Telescope and LSP servers)
