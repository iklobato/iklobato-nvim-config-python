# Neovim Configuration Guide

A modern Neovim configuration focused on Python/Django development with extensive LSP integration, debugging capabilities, AI assistance, and efficient navigation features.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Configuration Structure](#configuration-structure)
- [Key Mappings](#key-mappings)
  - [General](#general)
  - [Window Management](#window-management)
  - [File Navigation](#file-navigation)
  - [Code Navigation](#code-navigation)
  - [Git Integration](#git-integration)
  - [Debugging](#debugging)
  - [AI Assistant](#ai-assistant)
  - [Database Operations](#database-operations)
  - [REST Client](#rest-client)
  - [Terminal](#terminal)
- [Common Workflows](#common-workflows)
- [Customization](#customization)

## Features

- **Full Python Development Environment**: LSP support via Pyright and Ruff, Django-specific configurations
- **Comprehensive Debugging**: Python/Django debugging with DAP and interactive UI
- **Modern UI**: Status line, Git integration, file explorer, and clean theme
- **Intelligent Code Completion**: Context-aware suggestions via nvim-cmp with various sources
- **AI Code Assistant**: Integration with CodeCompanion for code explanations, fixes, and test generation
- **Database Integration**: SQL query execution and database management via vim-dadbod
- **REST Client**: HTTP request testing and JSON formatting
- **Session Management**: Automatic session saving and restoration

## Installation

1. Ensure you have the necessary dependencies:
   - Neovim 0.9+ (https://github.com/neovim/neovim/releases)
   - Node.js and npm (for LSP servers)
   - Git
   - Ripgrep (for Telescope searching)

2. Clone this configuration to your Neovim config directory:
   ```bash
   git clone https://github.com/yourusername/nvim-config.git ~/.config/nvim
   ```

3. Run the installation script (if provided):
   ```bash
   cd ~/.config/nvim
   ./install.sh
   ```

4. Launch Neovim, and plugins will be automatically installed.

## Configuration Structure

- `init.lua`: Main configuration entry point
- `lua/core/`: Core Neovim settings
  - `options.lua`: General editor options
  - `keymaps.lua`: Organized key mappings by functionality
- `lua/plugins/`: Plugin-specific configurations
- `ftplugin/`: Filetype-specific settings

## Key Mappings

> Note: The leader key is set to `<Space>`

### General
- `<leader>wq` - Save and quit
- `<leader>ww` - Save file
- `<leader>qq` - Quit without saving
- `gx` - Open URL under cursor

### Window Management
- `<leader>sv` - Split window vertically
- `<leader>sh` - Split window horizontally
- `<leader>se` - Make split windows equal width
- `<leader>sx` - Close split window
- `<leader>sm` - Toggle maximize current window

Size adjustments:
- `<leader>sj` - Decrease height
- `<leader>sk` - Increase height
- `<leader>sl` - Increase width

### File Navigation
- `<leader>ee` - Toggle file explorer
- `<leader>er` - Focus file explorer
- `<leader>ef` - Find current file in explorer

Telescope:
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>fr` - Recent files
- `<leader>fm` - Find methods
- `<leader>fo` - Find symbols in document
- `<leader>fi` - Find incoming calls
- `<leader>fs` - Find text in current buffer

### Code Navigation
LSP:
- `<leader>gd` - Go to definition
- `<leader>gD` - Go to declaration
- `<leader>gi` - Go to implementation
- `<leader>gr` - Find references
- `<leader>gt` - Go to type definition
- `<leader>gg` - Hover documentation
- `<leader>gs` - Show signature help
- `<leader>ga` - Code actions
- `<leader>lr` - Rename symbol
- `<leader>gf` - Format code

Diagnostics:
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>e` - Show diagnostic float
- `<leader>gl` - Show diagnostic float
- `<leader>gp` - Previous diagnostic
- `<leader>gn` - Next diagnostic
- `<leader>q` - List all diagnostics

Code Folding:
- `<leader>za` - Toggle fold
- `<leader>zA` - Toggle all folds
- `<leader>zo` - Open fold
- `<leader>zc` - Close fold
- `<leader>zR` - Open all folds
- `<leader>zM` - Close all folds

### Git Integration
- `<leader>gb` - Toggle git blame

### Debugging
- `<leader>bb` - Toggle breakpoint
- `<leader>bc` - Add conditional breakpoint
- `<leader>bl` - Add log point
- `<leader>br` - Clear all breakpoints
- `<leader>ba` - List all breakpoints

Debug Control:
- `<leader>dc` - Start/continue debugging
- `<leader>dj` - Step over
- `<leader>dk` - Step into
- `<leader>do` - Step out
- `<leader>dt` - Terminate debug session
- `<leader>dd` - Disconnect debugger
- `<leader>dl` - Run last configuration

Debug Info:
- `<leader>di` - Show variable information
- `<leader>d?` - Show scopes
- `<leader>dr` - Toggle REPL
- `<leader>df` - List frames
- `<leader>dh` - List commands
- `<leader>de` - List diagnostics

### AI Assistant
Normal Mode:
- `<leader>aa` - Open CodeCompanion actions
- `<leader>ac` - Toggle CodeCompanion chat
- `<leader>al` - Explain LSP error
- `<leader>am` - Generate commit message

Visual Mode:
- `<leader>aa` - Open CodeCompanion actions
- `<leader>ac` - Toggle CodeCompanion chat
- `<leader>ae` - Explain selected code
- `<leader>af` - Fix selected code
- `<leader>at` - Generate tests for selected code
- `<leader>as` - Add selection to chat

### Database Operations
- `<leader>db` - Toggle database UI
- `<leader>dq` - Execute query
- Visual mode `<leader>dq` - Execute selected query

### REST Client
- `<leader>rg` - Execute GET request
- `<leader>rp` - Execute POST request
- `<leader>ru` - Execute PUT request
- `<leader>rd` - Execute DELETE request
- `<leader>xr` - Run REST query
- `<leader>xj` - Format as JSON

### Terminal
- `<leader>tt` - Open terminal
- `<Esc>` - Exit terminal mode (when in terminal)

## Common Workflows

### 1. Python/Django Development
```
1. Navigate project with <leader>ff (find files) and <leader>fg (find in files)
2. Use <leader>gd to jump to definitions
3. View errors with <leader>e and fix with <leader>ga (code actions)
4. Format code with <leader>gf
5. Set breakpoints with <leader>bb at interesting points
6. Start debugging Django server with <leader>dc and select "DJANGO: Run Server"
7. Step through code with <leader>dj (over) and <leader>dk (into)
8. Inspect variables with <leader>di
9. Generate tests with visual <leader>at on a function
```

### 2. Database Operations
```
1. Configure connection in db_ui/connections.json
2. Open database UI with <leader>db
3. Navigate tables and browse data
4. Write custom query and execute with <leader>dq
5. See results in the query window
```

### 3. Using AI Assistant
```
1. Select code in visual mode
2. Use <leader>ae to get an explanation
3. Use <leader>af to suggest fixes
4. Use <leader>at to generate tests
5. Toggle chat with <leader>ac for more complex discussions
```

### 4. API Testing with REST Client
```
1. Create or open a .rest or .http file
2. Write a request like: GET https://api.example.com/posts
3. Position cursor on the request line
4. Press <leader>rg to execute the GET request
5. View response and format JSON with <leader>xj
```

### 5. Session Management
```
1. Work on project with multiple files, splits, etc.
2. Quit Neovim (session saved automatically)
3. Return to project and session will be restored
4. Use <leader>ss to search available sessions
5. Use <leader>sd to delete unwanted sessions
```

## Customization

### Adding New Plugins
1. Create a new file in `lua/plugins/` with this structure:
```lua
return {
  'author/plugin-name',
  dependencies = { -- optional
    'dependency1',
    'dependency2',
  },
  config = function()
    -- Configuration code here
  end
}
```

### Changing Theme
Edit `lua/plugins/colorscheme.lua` and uncomment your preferred theme configuration.

### Modifying Keymaps
Edit `lua/core/keymaps.lua` - organized by functionality sections for easy navigation.

This configuration is built for productive Python/Django development with quick access to common tasks. All key mappings are logically organized around the space key as leader.

