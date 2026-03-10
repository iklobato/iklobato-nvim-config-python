# Neovim Config (Minimal)

A flat, minimal Neovim setup focused on Python/Django with LSP, DAP, Telescope,
Treesitter, Conform, and Avante.

## Structure

```
init.lua                    # Main entry point
lua/
  core/                     # Core configuration
    init.lua
    options.lua
  plugins/                  # Modular plugin configurations
    init.lua                # Plugin loader
    core.lua                # Core plugins (treesitter, telescope, cmp, conform)
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
      python.lua
      lua.lua
      typescript.lua
      c.lua
  autocmds/                 # Organized autocommands
    init.lua                # Autocmd loader
    filetypes.lua           # Filetype-specific settings
    session.lua             # Session management
    ui.lua                  # UI-related autocommands
  config/                   # Plugin-specific configurations
    telescope.lua
    treesitter.lua
    cmp.lua
    conform.lua
    dap.lua
    dapui.lua
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
- nvim-cmp (cmp-nvim-lsp, cmp-buffer, cmp-path)
- telescope.nvim (plenary.nvim, telescope-dap.nvim)
- nvim-treesitter
- nvim-tree (nvim-web-devicons)
- conform.nvim
- nvim-dap + nvim-dap-ui (nvim-nio)
- avante.nvim (nui.nvim, plenary.nvim)
- auto-session

## LSP

- Servers: pyright, ruff, lua_ls
- Buffer-local LSP keymaps: `gd`, `gr`, `<leader>gr`, `gi`, `K`, `<leader>rn`, `<leader>ca`

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
- Avante: `<leader>aa`

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

## Avante

- Uses `avante.md` for project instructions
- Commands: `:AvanteToggle`, `:AvanteAsk`, `:AvanteChat`, `:AvanteEdit`

## Install

```bash
git clone https://github.com/iklobato/iklobato-nvim-config-python.git ~/.config/nvim
```

Open Neovim and let lazy.nvim install plugins.

## Requirements

- Neovim 0.11+
- Python 3 (for LSP and DAP)
- Node.js and ripgrep (for Telescope and LSP servers)
