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
- [Plugin Details and Usage Examples](#plugin-details-and-usage-examples)
  - [Nvim-Surround](#nvim-surround)
  - [Nvim-Tree File Explorer](#nvim-tree-file-explorer)
  - [Telescope Fuzzy Finder](#telescope-fuzzy-finder)
  - [DAP (Debug Adapter Protocol)](#dap-debug-adapter-protocol)
  - [Auto-Session](#auto-session)
  - [Vim-REST Console](#vim-rest-console)
  - [Database Interface](#database-interface-vim-dadbod)
  - [Git Blame Integration](#git-blame-integration)
  - [Treesitter Integration](#treesitter-integration)
- [Common Workflows](#common-workflows)
  - [Python/Django Development](#1-pythondjango-development)
    - [Python Development with CodeCompanion](#python-development-with-codecompanion)
  - [Database Operations](#2-database-operations)
  - [Using AI Assistant](#3-using-ai-assistant)
    - [CodeCompanion Components](#codecompanion-components)
    - [Advanced CodeCompanion Workflows](#advanced-codecompanion-workflows)
  - [API Testing](#4-api-testing-with-rest-client)
  - [Session Management](#5-session-management)
- [Customization](#customization)

## Features

- **Full Python Development Environment**: LSP support via Pyright and Ruff, Django-specific configurations
- **Comprehensive Debugging**: Python/Django debugging with DAP and interactive UI
- **Modern UI**: Status line, Git integration, file explorer, and clean theme
- **Intelligent Code Completion**: Context-aware suggestions via nvim-cmp with various sources
- **AI Code Assistant**: Integration with CodeCompanion for code explanations, fixes, test generation, and intelligent code refactoring
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
- `<leader>aa` - Open CodeCompanion actions (shows all available actions)
- `<leader>ac` - Toggle CodeCompanion chat (open/close chat window)
- `<leader>al` - Explain LSP error (analyze current diagnostic)
- `<leader>am` - Generate commit message (based on staged changes)

Visual Mode:
- `<leader>aa` - Open CodeCompanion actions menu
- `<leader>ac` - Toggle CodeCompanion chat with selected code
- `<leader>ae` - Explain selected code (get detailed analysis)
- `<leader>af` - Fix selected code (suggest improvements)
- `<leader>at` - Generate tests for selected code (create unit tests)
- `<leader>as` - Add selection to active chat (for context building)

Chat Buffer Commands:
- `<CR>` or `<C-s>` - Send message
- `<C-c>` - Close chat
- `q` - Stop current request
- `gy` - Yank last code block from chat
- `gd` - View current chat content in debug format

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

## Plugin Details and Usage Examples

### Nvim-Surround
The mini.surround plugin provides tools for working with pairs of characters (like quotes, parentheses, etc.).

**Key Usage Patterns:**
```
sa{motion}{char} - Add surrounding
sd{char}         - Delete surrounding
sr{target}{replacement} - Replace surrounding

Examples:
- saiw"          - Surround word with double quotes
- sdi(           - Delete surrounding parentheses
- sr"'           - Replace double quotes with single quotes
```

### Nvim-Tree File Explorer
File explorer with custom icons and git integration.

**Key Features:**
- File and directory browsing with icons
- Git status indicators
- File operations (create, delete, rename)
- Bookmarks and navigation

**Example Workflow:**
```
1. Open explorer with <leader>ee
2. Navigate to a file using j/k
3. Press o to open a file
4. Press a to add a new file
5. Press r to rename a file
6. Press d to delete a file
7. Press R to refresh the tree
```

### Telescope Fuzzy Finder
Powerful fuzzy finder for files, text, and more.

**Advanced Usage Examples:**
```
1. <leader>ff - Find files with live preview
2. <leader>fg - Find text with ripgrep
3. <leader>fm - Find methods in the current file (Treesitter)
4. <leader>fi - Find incoming calls to the current function
5. <leader>fb - Find and switch between open buffers
```

**Hidden File Search:**
```
1. In telescope, press <C-h> to toggle hidden files
2. Type !node_modules/ to exclude node_modules from results
3. Use * wildcards for pattern matching
```

### DAP (Debug Adapter Protocol)
Advanced debugging with breakpoints, stepping, and variable inspection.

**Django-Specific Debug Commands:**
```
1. Set breakpoints with <leader>bb at interesting points
2. Press <leader>dc to open the debug menu
3. Select "🌐 DJANGO: Run Server" to debug Django server
4. Select "🧪 DJANGO: Run Tests" to debug tests
5. Select "🔮 DJANGO: Shell Plus" for interactive shell debugging
6. Use <leader>di to inspect variables under cursor
```

**Working with Debug UI:**
```
1. Navigate between scopes, watches, and breakpoints panels
2. Expand variable objects with <CR> to explore nested values
3. Add watches with + in the watches panel
4. Set conditional breakpoints with <leader>bc
```

### Auto-Session
Automatic session management that remembers your workspace.

**Session Commands:**
```
1. <leader>ss - Search and load saved sessions
2. <leader>sd - Delete a session
```

**Session Features:**
- Automatically saves your session on exit
- Restores windows, buffers, and layout
- Git branch awareness for project-specific sessions

### Vim-REST Console
HTTP request testing tool integrated into Neovim.

**Request Example:**
```
# In a .rest or .http file:
GET https://api.example.com/users
Authorization: Bearer TOKEN
Content-Type: application/json

# Execute with <leader>rg or <leader>rr
```

**Working with Response Data:**
```
1. Write request in .rest file
2. Execute with <leader>rr
3. Response opens in split window as _OUTPUT.json
4. JSON is automatically formatted with jq
5. Navigate the response data
6. Use <leader>xj to reformat JSON if needed
```

### Database Interface (vim-dadbod)
Database client integration with Neovim for querying and viewing data.

**Database Connection:**
```
1. Configure connections in db_ui/connections.json
2. Open the database UI with <leader>db
3. Expand a connection to see tables and views
4. Click on a table to see its structure
```

**Writing Custom Queries:**
```
1. Open a SQL buffer with <leader>db
2. Write your SQL query
3. Position cursor anywhere in the query
4. Execute with <leader>dq
5. View results in the output window
6. Use visual selection to execute only part of a query
```

### Git Blame Integration
Git blame information in your editor.

**Usage:**
```
1. Toggle git blame with <leader>gb
2. See author, date, and commit message for each line
3. Press q to close blame information
```

### Treesitter Integration
Enhanced syntax highlighting and code navigation.

**Features:**
- Syntax highlighting based on language grammar
- Code folding based on structure
- Navigate between functions with ]m and [m
- View document symbols with <leader>fo
- Search for methods with <leader>fm

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

#### Python Development with CodeCompanion

##### Refactoring Django Views
```
1. Open your Django view file
2. Select a view function in visual mode
3. Press <leader>ac to open CodeCompanion chat
4. Type: "Help me refactor this view to use class-based views"
5. Review the suggested changes
6. Copy the code with gy in chat buffer or apply directly
```

##### Optimizing Database Queries
```
1. Select ORM queries in your Django code
2. Press <leader>ac to open CodeCompanion chat
3. Ask: "How can I optimize these database queries?"
4. Get suggestions for prefetch_related, select_related, or query refactoring
5. Apply the optimizations to your code
```

##### Debugging Complex API Issues
```
1. When facing an API issue, select the relevant code
2. Press <leader>ae to get an explanation
3. If CodeCompanion identifies the issue, press <leader>af to fix it
4. For deeper analysis, press <leader>ac and provide details like:
   "The API returns status 500 when I send this payload"
5. Get contextualized debugging steps and solutions
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

#### CodeCompanion Components

##### Understanding CodeCompanion Elements

CodeCompanion provides several powerful AI-assisted coding features:

- **Chat Buffer**: Interactive conversation window that maintains context
- **Action Palette**: Quick menu of common AI actions (<leader>aa)
- **Inline Assistant**: Direct code transformations from normal/visual mode
- **Prompt Library**: Built-in templates for common coding tasks

##### Using CodeCompanion Tags

CodeCompanion supports special tags in chat that enhance its capabilities:

- **@editor**: Gives CodeCompanion ability to modify your code directly
  ```
  @editor Please refactor this function to use async/await
  ```

- **@cmd_runner**: Lets CodeCompanion execute shell commands
  ```
  @cmd_runner Can you run the tests for this module?
  ```

- **#buffer**: Shares the current buffer with CodeCompanion for context
  ```
  #buffer What does this code do?
  ```

- **#selection**: Shares selected text with CodeCompanion
  ```
  #selection How can I optimize this function?
  ```

- **#lsp**: Sends LSP diagnostics to help with errors
  ```
  #lsp Why am I getting this error?
  ```

- **Special Roles**: Assign specific personas to CodeCompanion
  ```
  @code_reviewer Please review this implementation
  @security_expert Check this code for vulnerabilities
  @performance_engineer Optimize this algorithm
  ```

#### Advanced CodeCompanion Workflows

##### Explaining and Fixing Complex Code
```
1. Select a function or code block in visual mode
2. Press <leader>ae to get a detailed explanation
3. If you want improvements, press <leader>af to get suggestions
4. Review suggestions in the CodeCompanion chat buffer
5. Apply the changes directly using the suggested code from the chat
```

##### Debugging with CodeCompanion
```
1. When you encounter an LSP error, place cursor on the error
2. Press <leader>al to explain the error with CodeCompanion
3. Review explanation and suggested fixes
4. Implement the fix or press <leader>af to have CodeCompanion fix it
5. Test the solution to ensure the error is resolved
```

##### Generating Tests with Context
```
1. Select the function you want to test in visual mode
2. Press <leader>at to generate tests
3. In the CodeCompanion chat, type additional context like:
   "This test should mock the database connection"
4. Review the generated test code
5. Copy the test to your test file using gy in the chat buffer
```

##### Using Slash Commands
CodeCompanion's chat buffer supports special slash commands to trigger specific actions:

```
1. Open CodeCompanion chat with <leader>ac
2. Type one of these slash commands:
   - /explain - Explain the selected code
   - /fix - Fix issues in the code
   - /tests - Generate tests for the code
   - /commit - Generate a commit message
   - /refactor - Refactor selected code
   - /optimize - Optimize for performance
   - /docstring - Add documentation
   - /type - Add type annotations
   - /security - Check for security issues
3. The AI will respond with specialized output for that command
```

##### Multi-File Context Building
```
1. Start a CodeCompanion chat with <leader>ac
2. Use "#buffer" in a message to include current file
3. Open another related file and use <leader>as to add it to chat
4. Type a complex request like "Explain how these files work together"
5. Get comprehensive analysis across multiple files
```

##### Interactive Code Review
```
1. Select code for review in visual mode
2. Press <leader>ac to open chat with the selection
3. Type a specific question like "What potential edge cases am I missing?"
4. Get targeted feedback about your implementation
5. Iterate by adding more context with <leader>as
```

##### Creating Commit Messages
```
1. Stage your changes with git
2. Press <leader>am to generate a commit message
3. CodeCompanion will analyze the diff and suggest a meaningful message
4. Edit the message if needed
5. Accept or modify the suggested commit message
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

