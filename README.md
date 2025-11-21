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

- `init.lua`: Main configuration entry point, loads core settings and plugins.
- `lua/config/`: Core Neovim settings and general configurations.
  - `options.lua`: General editor options.
  - `keymaps.lua`: Organized key mappings by functionality.
  - `autocmds.lua`: Autocommands for various behaviors.
- `lua/plugins/`: Plugin-specific configurations, organized into subdirectories by category.
  - `lua/plugins/completion/`: Configuration for completion plugins (e.g., `nvim-cmp`).
  - `lua/plugins/ui/`: Configuration for UI-related plugins (e.g., `barbecue-nvim`, `lualine-nvim`, `nvim-tree`).
  - `lua/plugins/utility/`: Configuration for general utility plugins (e.g., `auto-session`, `nvim-autopairs`).
  - `lua/plugins/git/`: Configuration for Git integration plugins (e.g., `git-blame-nvim`).
  - `lua/plugins/linter/`: Configuration for linting plugins (e.g., `nvim-lint` with selene for Lua).
  - `lua/plugins/lsp/`: Configuration for LSP-related plugins (e.g., `nvim-lspconfig`, `nvim-dap-ui`).
  - `lua/plugins/syntax/`: Configuration for syntax highlighting and parsing (e.g., `nvim-treesitter`).
  - `lua/plugins/database/`: Configuration for database interaction plugins (e.g., `nvim-sql`, `vim-rest-console`).
  - `lua/plugins/formatter/`: Configuration for code formatting plugins (e.g., `conform-nvim`).
  - `lua/plugins/misc/`: Miscellaneous plugin configurations.
- `lua/lsp/`: Individual Language Server Protocol (LSP) client configurations.
- `scripts/`: Installation and utility scripts.
- `ftplugin/`: Filetype-specific settings.
- `stylua.toml`: Stylua formatter configuration for consistent Lua code formatting.
- `db_ui/`: Database UI configuration and runtime data.
  - `db_ui/connections.json.example`: Template for database connections (copy to `connections.json` and customize).

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
- `<leader>f` - Format code (via conform.nvim)

Diagnostics:
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>e` - Show diagnostic float
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

### Linting and Formatting
- `<leader>ll` - Lint buffer (show linting issues)
- `<leader>lf` - Auto-fix linting issues (Lua files)
- `<leader>f` - Format buffer (all file types)

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

This workflow guides you through a typical Python/Django development session, leveraging LSP, debugging, and AI assistance.

1.  **Navigate your project:**
    *   Find files quickly: `<leader>ff` (Telescope Find Files)
    *   Search for text across files: `<leader>fg` (Telescope Live Grep)
    *   Switch between open buffers: `<leader>fb` (Telescope Find Buffers)

2.  **Code Navigation and Understanding:**
    *   Jump to a definition: `<leader>gd` (Go to Definition)
    *   Find all references to a symbol: `<leader>gr` (Find References)
    *   View documentation for symbol under cursor: `<leader>gg` (Hover Documentation)
    *   Explain a complex code block (Visual Mode): Select code, then `<leader>ae` (CodeCompanion Explain)

3.  **Fixing and Refactoring Code:**
    *   View LSP diagnostics (errors/warnings): `<leader>e` (Show Diagnostic Float)
    *   Navigate between diagnostics: `[d` (Previous Diagnostic), `]d` (Next Diagnostic)
    *   Apply code actions (e.g., fix imports, refactor): `<leader>ga` (Code Actions)
    *   Format the current file: `<leader>f` (Format Code via conform.nvim)
    *   Fix selected code (Visual Mode): Select code, then `<leader>af` (CodeCompanion Fix)
    *   Generate tests for selected code (Visual Mode): Select code, then `<leader>at` (CodeCompanion Generate Tests)

4.  **Debugging Django Applications:**
    *   Set a breakpoint: Place cursor on line, then `<leader>bb` (Toggle Breakpoint)
    *   Start debugging Django server: `<leader>dc` (Debug Control), then select "🌐 DJANGO: Run Server"
    *   Step over code: `<leader>dj` (Step Over)
    *   Step into a function: `<leader>dk` (Step Into)
    *   Inspect variables: Place cursor on variable, then `<leader>di` (Show Variable Info)
    *   Open debug REPL: `<leader>dr` (Toggle REPL)
    *   Terminate debug session: `<leader>dt` (Terminate Debug Session)

5.  **Leveraging AI Assistant (CodeCompanion):**
    *   Open CodeCompanion actions menu: `<leader>aa` (Normal/Visual Mode)
    *   Toggle CodeCompanion chat: `<leader>ac` (Normal Mode)
    *   Explain LSP error under cursor: `<leader>al` (Explain LSP Error)
    *   Generate commit message based on staged changes: `<leader>am` (Generate Commit Message)
    *   Add current selection to active chat for context: `<leader>as` (Visual Mode)

#### Example: Refactoring a Django View with AI Assistance

1.  Open your Django `views.py` file.
2.  Visually select a view function you want to refactor (e.g., `V` to start visual mode, then move cursor).
3.  Press `<leader>ac` to open the CodeCompanion chat with the selected code as context.
4.  In the chat buffer, type: `Help me refactor this view to use class-based views.`
5.  Review the suggested changes provided by CodeCompanion.
6.  Copy the code block from the chat using `gy` (yank last code block) or apply it directly if CodeCompanion supports it.

#### Example: Optimizing Django Database Queries

1.  Open a Django model or view file containing ORM queries.
2.  Visually select the ORM query or a block of queries you want to optimize.
3.  Press `<leader>ac` to open the CodeCompanion chat.
4.  Ask: `How can I optimize these database queries? Consider prefetch_related and select_related.`
5.  CodeCompanion will provide suggestions. Apply the optimizations to your code.

#### Example: Debugging a Complex API Issue with AI

1.  When encountering an API issue (e.g., a 500 error), open the relevant code file.
2.  Visually select the code block suspected of causing the issue.
3.  Press `<leader>ae` to get an explanation of the selected code from CodeCompanion.
4.  If the explanation helps identify the problem, you can then press `<leader>af` to ask CodeCompanion to suggest a fix.
5.  For deeper analysis, open the chat with `<leader>ac` and provide more context, e.g., `The API returns status 500 when I send this payload: { "data": "example" }`. CodeCompanion can then offer more targeted debugging steps or solutions.

### 2. Database Operations

This section outlines how to interact with your databases directly from Neovim using `vim-dadbod`.

1.  **Configure Database Connections:**
    *   Edit `db_ui/connections.json` to add your database connection details (e.g., PostgreSQL, MySQL, SQLite).

2.  **Open the Database UI:**
    *   Toggle the database UI: `<leader>db`
    *   In the UI, navigate through your configured connections, databases, and tables.
    *   Expand a connection to see available tables and views.
    *   Press `Enter` on a table name to view its schema or browse its data.

3.  **Write and Execute Custom Queries:**
    *   Open a new SQL buffer: While in the database UI, press `s` on a connection to open a new SQL buffer connected to that database.
    *   Write your SQL query in the buffer.
    *   Execute the entire query: Place your cursor anywhere within the query, then `<leader>dq`.
    *   Execute a selected portion of a query: Visually select the SQL you want to run, then `<leader>dq`.
    *   View results: The query results will appear in a new split window.

#### Example: Browsing a Django Database and Running a Custom Query

1.  Ensure your Django database connection is configured in `db_ui/connections.json`.
2.  Press `<leader>db` to open the database UI.
3.  Navigate to your Django database connection and expand it.
4.  Browse the `auth_user` table to see its columns and some data.
5.  Press `s` on your Django connection to open a new SQL buffer.
6.  Type the following query:
    ```sql
    SELECT id, username, email FROM auth_user WHERE is_staff = TRUE;
    ```
7.  Place your cursor on any line of the query and press `<leader>dq`.
8.  The results (staff users) will be displayed in a new buffer.

### 3. Using AI Assistant

This section details how to effectively use the integrated AI assistant (CodeCompanion) for various coding tasks.

1.  **Basic AI Interactions (Normal/Visual Mode):**
    *   **Explain Code:** Visually select code, then `<leader>ae` to get a detailed explanation.
    *   **Fix Code:** Visually select code, then `<leader>af` to get suggestions for fixing issues.
    *   **Generate Tests:** Visually select code, then `<leader>at` to generate unit tests for it.
    *   **Toggle Chat:** `<leader>ac` (Normal Mode) to open/close the interactive chat window.
    *   **Open Actions Menu:** `<leader>aa` (Normal/Visual Mode) to see all available CodeCompanion actions.

2.  **Advanced Chat Workflows:**
    *   **Start a new chat with selected code:** Visually select code, then `<leader>ac`.
    *   **Add current selection to active chat:** While in visual mode, press `<leader>as` to add the selected text to the ongoing chat context.
    *   **Send message in chat:** Press `<CR>` or `<C-s>` in the chat buffer.
    *   **Close chat:** Press `<C-c>` in the chat buffer.
    *   **Stop current request:** Press `q` in the chat buffer.
    *   **Yank last code block from chat:** `gy` in the chat buffer.
    *   **View chat content in debug format:** `gd` in the chat buffer.

3.  **Using CodeCompanion Tags for Context and Control:**
    CodeCompanion supports special tags in chat messages to provide additional context or control its behavior:

    *   `@editor`: Grants CodeCompanion permission to modify your code directly.
        ```
        @editor Please refactor this function to use async/await.
        ```
    *   `@cmd_runner`: Allows CodeCompanion to execute shell commands.
        ```
        @cmd_runner Can you run the tests for this module?
        ```
    *   `#buffer`: Shares the content of the current buffer with CodeCompanion for context.
        ```
        #buffer What does this code do?
        ```
    *   `#selection`: Shares the currently selected text with CodeCompanion.
        ```
        #selection How can I optimize this function?
        ```
    *   `#lsp`: Sends LSP diagnostics to help CodeCompanion understand and fix errors.
        ```
        #lsp Why am I getting this error?
        ```
    *   **Special Roles**: Assign specific personas to CodeCompanion for specialized feedback.
        ```
        @code_reviewer Please review this implementation.
        @security_expert Check this code for vulnerabilities.
        @performance_engineer Optimize this algorithm.
        ```

4.  **Slash Commands in Chat:**
    CodeCompanion's chat buffer supports special slash commands to trigger specific actions:

    *   Open CodeCompanion chat with `<leader>ac`.
    *   Type one of these slash commands followed by your prompt:
        *   `/explain`: Explain the selected code.
        *   `/fix`: Fix issues in the code.
        *   `/tests`: Generate tests for the code.
        *   `/commit`: Generate a commit message.
        *   `/refactor`: Refactor selected code.
        *   `/optimize`: Optimize for performance.
        *   `/docstring`: Add documentation.
        *   `/type`: Add type annotations.
        *   `/security`: Check for security issues.

#### Example: Multi-File Context Building for Complex Analysis

1.  Start a CodeCompanion chat with `<leader>ac`.
2.  In the chat buffer, type a message including `#buffer` to include the current file's content, e.g., `Here's my main application file: #buffer`.
3.  Open another related file (e.g., a utility file or a model) and visually select a relevant section.
4.  Press `<leader>as` to add this selection to the active chat context.
5.  Now, type a complex request like: `Explain how these two files work together to handle user authentication.`
6.  CodeCompanion will provide a comprehensive analysis across both files, leveraging the context you provided.

#### Example: Interactive Code Review with AI

1.  Visually select a code block you want reviewed.
2.  Press `<leader>ac` to open a chat with the selection as context.
3.  Type a specific question like: `What potential edge cases am I missing in this error handling logic?`
4.  CodeCompanion will provide targeted feedback.
5.  You can iterate by adding more context with `<leader>as` or asking follow-up questions.

### 4. API Testing with REST Client

This section explains how to use the integrated REST client (`vim-rest-console`) for testing APIs.

1.  **Create or Open a Request File:**
    *   Create a new file with a `.rest` or `.http` extension (e.g., `api_test.rest`).
    *   Write your HTTP request in this file. For example:
        ```http
        GET https://jsonplaceholder.typicode.com/posts/1
        Content-Type: application/json

        ###

        POST https://jsonplaceholder.typicode.com/posts
        Content-Type: application/json

        {
          "title": "foo",
          "body": "bar",
          "userId": 1
        }
        ```

2.  **Execute Requests:**
    *   Place your cursor on the line of the request you want to execute.
    *   Execute a GET request: `<leader>rg`
    *   Execute a POST request: `<leader>rp`
    *   Execute a PUT request: `<leader>ru`
    *   Execute a DELETE request: `<leader>rd`
    *   Alternatively, use `<leader>xr` to execute the request under the cursor (works for any method).

3.  **View and Format Response:**
    *   The API response will open in a new split window (e.g., `_OUTPUT.json`).
    *   If the response is JSON, it will be automatically formatted.
    *   If you need to reformat the JSON (e.g., after manual edits), press `<leader>xj`.

#### Example: Testing a Public API

1.  Create a file named `test_api.rest`.
2.  Add the following content:
    ```http
    GET https://api.github.com/users/octocat
    ```
3.  Place your cursor on the `GET` line and press `<leader>rg`.
4.  A new buffer will open with the JSON response from the GitHub API, showing details for the `octocat` user.

### 5. Session Management

This section explains how automatic session management works and how to manually control sessions.

1.  **Automatic Session Saving and Restoration:**
    *   When you exit Neovim from a project directory, your current session (open files, window layouts, buffer states) is automatically saved.
    *   When you reopen Neovim in the same project directory, the saved session is automatically restored, allowing you to pick up exactly where you left off.
    *   This feature is particularly useful for maintaining context across different projects or work sessions.

2.  **Manually Managing Sessions:**
    *   **Search and Load Sessions:** `<leader>ss` (Telescope Search Sessions) to view a list of all saved sessions. You can fuzzy-find and select a session to load it.
    *   **Delete a Session:** `<leader>sd` (Telescope Delete Session) to view a list of saved sessions and select one to delete.

#### Example: Switching Between Projects with Sessions

1.  Open Neovim in `~/projects/project_a`.
2.  Open several files, create some splits, and make some edits.
3.  Exit Neovim (`:wq` or `:q`). The session for `project_a` is automatically saved.
4.  Open Neovim in `~/projects/project_b`.
5.  Work on `project_b`, opening different files and layouts.
6.  Now, you want to go back to `project_a`.
7.  Press `<leader>ss`.
8.  Select the session corresponding to `project_a` from the list.
9.  Neovim will close `project_b`'s session and restore `project_a`'s session, including all its open buffers and window layouts.

## Customization

### Adding New Plugins
1. Create a new file in the appropriate subdirectory under `lua/plugins/` (e.g., `lua/plugins/completion/my-new-plugin.lua`).
2. Use this structure:
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
Edit `lua/plugins/ui/colorscheme.lua` and uncomment your preferred theme configuration.

### Modifying Keymaps
Edit `lua/config/keymaps.lua` - organized by functionality sections for easy navigation.

### Lua Linting and Formatting

This configuration includes automatic Lua linting and formatting:

- **Linting**: Uses `nvim-lint` with `selene` for Lua code linting
  - Automatically lints on file save and when opening files
  - Manual lint: `<leader>ll` (Lint buffer)
  - Auto-fix: `<leader>lf` (Auto-fix linting issues)
  
- **Formatting**: Uses `stylua` via `conform.nvim` for Lua code formatting
  - Automatically formats on save
  - Manual format: `<leader>f` (Format buffer)
  - Configuration: `stylua.toml` in the config root

**Installation Requirements:**
- Install `selene`: `cargo install selene` or via your package manager
- Install `stylua`: `cargo install stylua` or via your package manager
- Alternatively, both can be installed via Mason: `:MasonInstall selene stylua`

**Configuration Files:**
- `stylua.toml`: Stylua formatter configuration (indentation, line width, etc.)
- `lua/plugins/linter/nvim-lint.lua`: Linter configuration

This configuration is built for productive Python/Django development with quick access to common tasks. All key mappings are logically organized around the space key as leader.

