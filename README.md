# Neovim Configuration Guide

A modern Neovim configuration focused on Python/Django development with extensive LSP integration, debugging capabilities, AI assistance, and efficient navigation features.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Configuration Structure](#configuration-structure)
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
  - [Debugging Workflows](#6-debugging-workflows)
- [Python Development Examples](#python-development-examples)
- [Plugin Shortcuts Cheatsheet](#plugin-shortcuts-cheatsheet)
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

### Quick Install (One-liner)

Install this Neovim configuration with a single command:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/iklobato/iklobato-nvim-config-python/main/install.sh)
```

Or using git clone:

```bash
git clone --depth=1 https://github.com/iklobato/iklobato-nvim-config-python.git /tmp/nvim-config-install && bash /tmp/nvim-config-install/install.sh && rm -rf /tmp/nvim-config-install
```

The installation script will:
- **Automatically detect your OS** (macOS or Ubuntu/Debian)
- **Install all required dependencies** (Neovim 0.10.0+, Git, Node.js, Ripgrep, Python 3)
- Prompt you to backup existing Neovim config (if present)
- Clone the repository and install configuration files
- Set up the configuration directory

**Supported OS:** macOS (via Homebrew) and Ubuntu/Debian (via apt-get)

**Note:** Plugins will be automatically installed by lazy.nvim when you first launch Neovim. No manual plugin installation needed!

### Manual Installation

If you prefer to install manually:

1. Ensure you have the necessary dependencies:
   - Neovim 0.10.0+ (https://github.com/neovim/neovim/releases) - Required for vim.loader support
   - Node.js and npm (for LSP servers)
   - Git
   - Ripgrep (for Telescope searching)
   - Python 3 (for Pyright and Ruff LSP servers)

2. Clone this configuration to your Neovim config directory:
   ```bash
   git clone https://github.com/iklobato/iklobato-nvim-config-python.git ~/.config/nvim
   ```

3. Launch Neovim, and plugins will be automatically installed by lazy.nvim.

### Font Configuration (Required for Icons)

This configuration uses Nerd Fonts to display file icons in the file explorer, status line, and other UI elements.

**Automatic Installation:**
The install script automatically installs Meslo LG Nerd Font on Ubuntu. However, you must configure your terminal to use it.

**Manual Font Installation (Ubuntu):**
```bash
# Create fonts directory
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download Meslo LG Nerd Font
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -o Meslo.zip
unzip Meslo.zip
rm Meslo.zip

# Update font cache
fc-cache -fv
```

**Configure Terminal:**

1. **GNOME Terminal:** Edit > Preferences > Text > Custom font > Select "MesloLGS Nerd Font"
2. **VS Code Terminal:** Add to `settings.json`:
   ```json
   {
     "terminal.integrated.fontFamily": "MesloLGS Nerd Font"
   }
   ```
3. **Other terminals:** Check terminal settings for font configuration

**Verify Installation:**
```bash
# Check if font is installed
fc-list | grep -i "meslo.*nerd"

# Restart terminal and Neovim after font change
```

**Troubleshooting:**

- If icons show as Chinese/Korean characters: Terminal font is not set to Nerd Font
- If icons show as boxes: Font cache needs refresh (`fc-cache -fv`)
- If no icons appear: Check that `nvim-web-devicons` plugin is loaded

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

## Plugin Details and Usage Examples

> **Note**: For a complete list of keyboard shortcuts, see the [Plugin Shortcuts Cheatsheet](#plugin-shortcuts-cheatsheet) section.

This section provides an overview of the installed plugins, their purpose, and when to use them. For detailed keyboard shortcuts and quick reference, see the [Plugin Shortcuts Cheatsheet](#plugin-shortcuts-cheatsheet).

### Nvim-Surround
The mini.surround plugin provides tools for working with pairs of characters (like quotes, parentheses, etc.). It allows you to quickly add, delete, or replace surrounding characters around text selections.

**When to use:**
- Wrapping text in quotes or brackets
- Changing quote types (single to double quotes)
- Removing surrounding characters

**Key Usage Patterns:**
- `sa{motion}{char}` - Add surrounding
- `sd{char}` - Delete surrounding
- `sr{target}{replacement}` - Replace surrounding

See [Plugin Shortcuts Cheatsheet](#code-editing) for all shortcuts.

### Nvim-Tree File Explorer
File explorer with custom icons and git integration. Provides a visual file tree for navigating your project structure.

**Key Features:**
- File and directory browsing with icons
- Git status indicators
- File operations (create, delete, rename)
- Bookmarks and navigation

**When to use:**
- Exploring project structure
- Quick file operations (create, delete, rename)
- Visual navigation of directories

See [Plugin Shortcuts Cheatsheet](#file-navigation) for shortcuts.

### Telescope Fuzzy Finder
Powerful fuzzy finder for files, text, and more. The primary tool for finding files, searching text, and navigating your codebase.

**Key Features:**
- Fuzzy file finding with live preview
- Text search across files (ripgrep integration)
- Buffer navigation
- Symbol and method finding
- Recent files

**When to use:**
- Finding files quickly
- Searching for text across the codebase
- Switching between open buffers
- Finding functions, classes, or methods

**Tips:**
- Press `<C-h>` in Telescope to toggle hidden files
- Use `!node_modules/` to exclude directories from results
- Use `*` wildcards for pattern matching

See [Plugin Shortcuts Cheatsheet](#file-navigation) for all shortcuts.

### DAP (Debug Adapter Protocol)
Advanced debugging with breakpoints, stepping, and variable inspection. Provides a full debugging experience for Python and Django applications.

**Key Features:**
- Breakpoint management
- Step debugging (into, over, out)
- Variable inspection
- Django-specific debug configurations
- Interactive REPL in debug context

**When to use:**
- Debugging Python code
- Debugging Django applications
- Inspecting variable values
- Testing code execution flow

**Django-Specific Configurations:**
- Debug Django server
- Debug Django tests
- Debug Django shell
- Debug custom management commands

See [Plugin Shortcuts Cheatsheet](#debugging) for all shortcuts and [Common Workflows](#1-pythondjango-development) for usage examples.

### Auto-Session
Automatic session management that remembers your workspace. Saves and restores your editor state (open files, window layouts, buffer states) automatically.

**Key Features:**
- Automatic session saving on exit
- Automatic session restoration on open
- Project-based sessions (by directory)
- Git branch awareness

**When to use:**
- Switching between multiple projects
- Resuming work after closing Neovim
- Maintaining context across work sessions

See [Plugin Shortcuts Cheatsheet](#utilities) for shortcuts and [Common Workflows](#5-session-management) for usage examples.

### Vim-REST Console
HTTP request testing tool integrated into Neovim. Allows you to write and execute HTTP requests directly in your editor.

**Key Features:**
- Execute GET, POST, PUT, DELETE requests
- JSON response formatting
- Request/response viewing in split windows

**When to use:**
- Testing API endpoints
- Debugging REST APIs
- Quick API exploration

**Request Example:**
```
# In a .rest or .http file:
GET https://api.example.com/users
Authorization: Bearer TOKEN
Content-Type: application/json
```

See [Plugin Shortcuts Cheatsheet](#database--api) for all shortcuts and [Common Workflows](#4-api-testing-with-rest-client) for usage examples.

### Database Interface (vim-dadbod)
Database client integration with Neovim for querying and viewing data. Provides a UI for browsing databases, tables, and executing SQL queries.

**Key Features:**
- Visual database browser
- SQL query execution
- Connection management
- Query result viewing

**When to use:**
- Browsing database structure
- Executing SQL queries
- Viewing table data
- Testing database queries

**Configuration:**
- Configure connections in `db_ui/connections.json` (see `db_ui/connections.json.example` for template)
- Supports PostgreSQL, MySQL, SQLite, MongoDB, and more

See [Plugin Shortcuts Cheatsheet](#database--api) for shortcuts and [Common Workflows](#2-database-operations) for usage examples.

### Git Blame Integration
Git blame information displayed inline in your editor. Shows author, date, and commit message for each line of code.

**When to use:**
- Understanding code history
- Finding who wrote specific code
- Reviewing commit information

See [Plugin Shortcuts Cheatsheet](#git-integration) for shortcuts.

### Treesitter Integration
Enhanced syntax highlighting and code navigation based on language grammars. Provides more accurate syntax highlighting and enables advanced code navigation features.

**Key Features:**
- Syntax highlighting based on language grammar
- Code folding based on structure
- Method/function navigation
- Symbol finding

**When to use:**
- Better syntax highlighting
- Navigating code structure
- Finding functions and methods

See [Plugin Shortcuts Cheatsheet](#syntax--navigation) for shortcuts.

## Common Workflows

### 1. Python/Django Development

This workflow guides you through a typical Python/Django development session, leveraging LSP, debugging, and AI assistance. For detailed keyboard shortcuts, see the [Plugin Shortcuts Cheatsheet](#plugin-shortcuts-cheatsheet).

1.  **Navigate your project:**
    *   Find files quickly using Telescope (see [Plugin Shortcuts Cheatsheet - File Navigation](#file-navigation))
    *   Search for text across files using live grep
    *   Switch between open buffers

2.  **Code Navigation and Understanding:**
    *   Jump to definitions and find references using LSP (see [Plugin Shortcuts Cheatsheet - LSP & Diagnostics](#lsp--diagnostics))
    *   View documentation for symbols under cursor
    *   Explain complex code blocks using CodeCompanion (see [Plugin Shortcuts Cheatsheet - AI Assistant](#ai-assistant))

3.  **Fixing and Refactoring Code:**
    *   View and navigate LSP diagnostics
    *   Apply code actions for quick fixes
    *   Format code automatically on save
    *   Use CodeCompanion to fix and generate tests (see [Python Development Examples](#python-development-examples) for detailed examples)

4.  **Debugging Django Applications:**
    *   Set breakpoints and debug Django applications (see [Plugin Shortcuts Cheatsheet - Debugging](#debugging))
    *   Use Django-specific debug configurations (server, tests, shell)
    *   Inspect variables and step through code
    *   Use debug REPL for interactive testing

5.  **Leveraging AI Assistant (CodeCompanion):**
    *   Use CodeCompanion for code explanations, fixes, and test generation
    *   Generate commit messages from staged changes
    *   Build context in chat for complex refactoring tasks

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

This section outlines how to interact with your databases directly from Neovim using `vim-dadbod`. For keyboard shortcuts, see [Plugin Shortcuts Cheatsheet - Database & API](#database--api).

1.  **Configure Database Connections:**
    *   Edit `db_ui/connections.json` to add your database connection details (e.g., PostgreSQL, MySQL, SQLite).
    *   See `db_ui/connections.json.example` for a template.

2.  **Open the Database UI:**
    *   Toggle the database UI to browse your databases
    *   Navigate through your configured connections, databases, and tables
    *   Expand a connection to see available tables and views
    *   Press `Enter` on a table name to view its schema or browse its data

3.  **Write and Execute Custom Queries:**
    *   Open a new SQL buffer from the database UI
    *   Write your SQL query in the buffer
    *   Execute queries (entire buffer or selected portion)
    *   View results in a new split window

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

This section details how to effectively use the integrated AI assistant (CodeCompanion) for various coding tasks. For keyboard shortcuts, see [Plugin Shortcuts Cheatsheet - AI Assistant](#ai-assistant).

1.  **Basic AI Interactions (Normal/Visual Mode):**
    *   **Explain Code:** Visually select code and get detailed explanations
    *   **Fix Code:** Get suggestions for fixing issues in selected code
    *   **Generate Tests:** Generate unit tests for selected code
    *   **Toggle Chat:** Open/close the interactive chat window
    *   **Open Actions Menu:** See all available CodeCompanion actions

2.  **Advanced Chat Workflows:**
    *   **Start a new chat with selected code:** Visually select code to begin a chat with context
    *   **Add current selection to active chat:** Build context by adding selections to ongoing chat
    *   **Chat buffer commands:** Send messages, close chat, stop requests, and extract code blocks

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

This section explains how to use the integrated REST client (`vim-rest-console`) for testing APIs. For keyboard shortcuts, see [Plugin Shortcuts Cheatsheet - Database & API](#database--api).

1.  **Create or Open a Request File:**
    *   Create a new file with a `.rest` or `.http` extension (e.g., `api_test.rest`)
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

This section explains how automatic session management works and how to manually control sessions. For keyboard shortcuts, see [Plugin Shortcuts Cheatsheet - Utilities](#utilities).

1.  **Automatic Session Saving and Restoration:**
    *   Sessions are automatically saved when you exit Neovim from a project directory
    *   Sessions are automatically restored when you reopen Neovim in the same project directory
    *   Includes open files, window layouts, and buffer states
    *   Particularly useful for maintaining context across different projects or work sessions

2.  **Manually Managing Sessions:**
    *   **Search and Load Sessions:** View and load saved sessions using Telescope
    *   **Delete a Session:** Remove unwanted sessions

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

### 6. Debugging Workflows

This section provides comprehensive step-by-step guides for debugging different types of Python code. For keyboard shortcuts, see [Plugin Shortcuts Cheatsheet - Debugging](#debugging).

#### Debugging Regular Python Scripts

**Use Case**: Debugging standalone Python files, scripts, or modules that aren't part of a Django project.

**Example Script** (`calculate.py`):
```python
def calculate_total(items):
    total = 0
    for item in items:  # Set breakpoint here
        total += item.get('price', 0)
    return total

if __name__ == '__main__':
    items = [{'price': 10}, {'price': 20}, {'name': 'free'}]
    result = calculate_total(items)
    print(f"Total: {result}")
```

**Step-by-Step**:
1. Open the Python file: `<leader>ff`, type filename
2. Set breakpoint: Place cursor on the line where you want to pause (e.g., line 3), press `<leader>bb` (red dot appears)
3. Start debugging: Press `<leader>dc` (Debug Control)
4. Select configuration: Choose "🐍 PYTHON: Current File"
5. When breakpoint hits:
   - **Inspect variables**: Hover over `item` or press `<leader>di` on the variable
   - **View all variables**: Press `<leader>d?` to see all variables in current scope
   - **Step through code**: 
     - `<leader>dj` (Step Over) - Execute current line, don't enter functions
     - `<leader>dk` (Step Into) - Enter function calls
     - `<leader>do` (Step Out) - Exit current function
   - **Use REPL**: Press `<leader>dr` to open Python REPL, test expressions:
     ```python
     >>> item.get('price', 0)
     10
     >>> total
     0
     ```
6. Continue execution: Press `<leader>dc` to continue to next breakpoint or end
7. Terminate: Press `<leader>dt` when done

**Tips**:
- Set multiple breakpoints in different functions
- Use conditional breakpoints: `<leader>bc`, enter condition like `len(items) > 5`
- Use logpoints: `<leader>bl`, enter message like `Items: {items}, Total: {total}` to log without stopping

#### Debugging Django Views

**Use Case**: Debugging Django view functions, class-based views, or API endpoints.

**Example View** (`views.py`):
```python
from django.http import JsonResponse
from .models import Product

def product_list(request):
    category = request.GET.get('category')  # Set breakpoint here
    products = Product.objects.filter(category=category) if category else Product.objects.all()
    data = [{'id': p.id, 'name': p.name} for p in products]
    return JsonResponse(data, safe=False)
```

**Step-by-Step**:
1. Open the view file: `<leader>ff`, navigate to `views.py`
2. Set breakpoint: Place cursor on the line you want to debug, press `<leader>bb`
3. Start Django server in debug mode: Press `<leader>dc`, select "🌐 DJANGO: Run Server"
4. Trigger the view: 
   - Use REST client: Create `.rest` file, make GET request to the endpoint
   - Or use browser: Navigate to the URL
   - Or use curl/Postman
5. When breakpoint hits:
   - **Inspect request**: 
     - Hover over `request` or press `<leader>di` on `request`
     - Check `request.GET`: Use REPL (`<leader>dr`), type `request.GET.get('category')`
     - Check `request.POST`: In REPL, type `request.POST`
     - Check `request.user`: In REPL, type `request.user.username`
   - **Inspect queryset**: In REPL, type `list(products.values('id', 'name'))`
   - **Step through logic**: Use `<leader>dj` to step over, `<leader>dk` to step into
   - **View call stack**: Press `<leader>df` to see how you got to this view
6. Continue or terminate: Press `<leader>dc` to continue, `<leader>dt` to stop

**Advanced**:
- Debug class-based views: Set breakpoint in `get()`, `post()`, or other methods
- Debug middleware: Set breakpoint in middleware `process_request()` method
- Debug template context: Set breakpoint in view, inspect context variables before rendering

#### Debugging Django Models

**Use Case**: Debugging model methods, properties, signals, or model validation.

**Example Model** (`models.py`):
```python
from django.db import models

class Product(models.Model):
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    
    def get_discounted_price(self, discount=0.1):  # Set breakpoint here
        return self.price * (1 - discount)
    
    @property
    def is_expensive(self):  # Set breakpoint here
        return self.price > 100
```

**Step-by-Step**:
1. Open the model file: `<leader>ff`, navigate to `models.py`
2. Set breakpoint in model method: Place cursor in the method, press `<leader>bb`
3. Start Django shell in debug mode: Press `<leader>dc`, select "🔮 DJANGO: Shell Plus"
4. In the shell, create or retrieve a model instance:
   ```python
   >>> product = Product.objects.first()
   >>> product.get_discounted_price(0.2)  # This will hit the breakpoint
   ```
5. When breakpoint hits:
   - **Inspect `self`**: Press `<leader>di` on `self` to see model instance
   - **Check attributes**: In REPL, type `self.name`, `self.price`
   - **Test method logic**: In REPL, test calculations
6. For property debugging: Access the property in shell, breakpoint will trigger
7. Continue or terminate: Press `<leader>dc` or `<leader>dt`

**Debugging Signals**:
1. Set breakpoint in signal handler
2. Start Django shell: `<leader>dc` → "🔮 DJANGO: Shell Plus"
3. Perform action that triggers signal (e.g., `Product.objects.create(...)`)
4. Breakpoint will hit in signal handler

#### Debugging Django Tests (Django Test Framework)

**Use Case**: Debugging tests written with Django's test framework.

**Example Test** (`test_models.py`):
```python
from django.test import TestCase
from .models import Product

class ProductModelTest(TestCase):
    def setUp(self):
        self.product = Product.objects.create(name="Test", price=50)
    
    def test_get_discounted_price(self):
        result = self.product.get_discounted_price(0.2)  # Set breakpoint here
        self.assertEqual(result, 40)
```

**Step-by-Step**:
1. Open the test file: `<leader>ff`, navigate to test file
2. Set breakpoint: Place cursor in the test method, press `<leader>bb`
3. Start debugging: Press `<leader>dc`, select "🧪 DJANGO: Run Tests"
4. Enter test path: 
   - For specific test: `test_models.ProductModelTest.test_get_discounted_price`
   - For all tests in file: `test_models`
   - For all tests: Leave empty
5. When breakpoint hits:
   - **Inspect test data**: Press `<leader>di` on `self.product`
   - **Check assertions**: In REPL, test `self.product.get_discounted_price(0.2)`
   - **View test database**: In REPL, type `Product.objects.all()`
   - **Step through test logic**: Use `<leader>dj` or `<leader>dk`
6. Continue or terminate: Press `<leader>dc` to continue, `<leader>dt` to stop

**Rerunning Last Test**:
- Press `<leader>dl` to rerun the last debugged test command
- Or use "⏮️ DJANGO: Rerun Last Command" from `<leader>dc`

#### Debugging Pytest Tests

**Use Case**: Debugging tests written with pytest.

**Example Test** (`test_calculations.py`):
```python
import pytest
from myapp.calculations import calculate_total

def test_calculate_total():
    items = [{'price': 10}, {'price': 20}]
    result = calculate_total(items)  # Set breakpoint here
    assert result == 30
```

**Step-by-Step**:
1. Open the test file: `<leader>ff`, navigate to pytest test file
2. Set breakpoint: Place cursor in test function, press `<leader>bb`
3. Start debugging: Press `<leader>dc`, select one of:
   - "🎯 PYTEST: Run All Tests" - Run all pytest tests
   - "🔍 PYTEST: Current File" - Run tests in current file
   - "🛠️ PYTEST: Custom Path/Args" - Run specific test with custom arguments
4. If using custom path:
   - Enter test path: `test_calculations.py::test_calculate_total`
   - Enter extra args (optional): `-v -k "test_calculate"`
5. When breakpoint hits:
   - **Inspect test data**: Press `<leader>di` on variables
   - **Test assertions**: In REPL, verify expected values
   - **Step through**: Use `<leader>dj` or `<leader>dk`
6. Continue or terminate: Press `<leader>dc` or `<leader>dt`

**Pytest-Specific Tips**:
- Use "🛠️ PYTEST: Custom Path/Args" for pytest-specific flags like `-k`, `-m`, `-x`
- Debug fixtures: Set breakpoint in fixture function
- Debug parametrized tests: Breakpoint will hit for each parameter combination

#### Debugging Django Management Commands

**Use Case**: Debugging custom Django management commands.

**Example Command** (`management/commands/import_data.py`):
```python
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    def handle(self, *args, **options):
        filename = options['file']  # Set breakpoint here
        data = self.load_data(filename)
        self.process_data(data)
    
    def load_data(self, filename):
        # Set breakpoint here
        with open(filename) as f:
            return json.load(f)
```

**Step-by-Step**:
1. Open the management command file: `<leader>ff`, navigate to command file
2. Set breakpoint: Place cursor in `handle()` method or other methods, press `<leader>bb`
3. Start debugging: Press `<leader>dc`, select "⚙️ DJANGO: Custom Command"
4. Enter command: Type the management command name and arguments:
   - Example: `import_data --file data.json`
   - Example: `migrate`
   - Example: `createsuperuser`
5. When breakpoint hits:
   - **Inspect options**: Press `<leader>di` on `options` to see command arguments
   - **Check args**: In REPL, type `args` to see positional arguments
   - **Step through command logic**: Use `<leader>dj` or `<leader>dk`
   - **Test data processing**: In REPL, test functions with sample data
6. Continue or terminate: Press `<leader>dc` or `<leader>dt`

**Rerunning Commands**:
- After running a command, use "⏮️ DJANGO: Rerun Last Command" to quickly rerun it
- The last command is stored automatically

#### Debugging Django Shell

**Use Case**: Interactive debugging and testing in Django shell context.

**Step-by-Step**:
1. Start Django shell in debug mode: Press `<leader>dc`, select "🔮 DJANGO: Shell Plus"
2. Shell opens with debugger attached
3. Set breakpoints in any file: Open file, place cursor, press `<leader>bb`
4. Execute code in shell that triggers breakpoint:
   ```python
   >>> from myapp.models import Product
   >>> product = Product.objects.first()
   >>> product.get_discounted_price(0.2)  # If breakpoint in method
   ```
5. When breakpoint hits:
   - **Inspect variables**: Use `<leader>di` or REPL
   - **Test expressions**: Use REPL (`<leader>dr`) to test code
   - **Step through**: Use `<leader>dj`, `<leader>dk`, `<leader>do`
6. Continue or terminate: Press `<leader>dc` or `<leader>dt`

**Tips**:
- Use shell plus for better experience (includes IPython if available)
- Test ORM queries before using in views
- Debug model methods interactively

#### Debugging API Endpoints (REST/DRF)

**Use Case**: Debugging Django REST Framework views, serializers, or API endpoints.

**Example API View** (`views.py`):
```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .serializers import ProductSerializer

@api_view(['GET', 'POST'])
def product_list(request):
    if request.method == 'POST':
        serializer = ProductSerializer(data=request.data)  # Set breakpoint here
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
    else:
        products = Product.objects.all()
        serializer = ProductSerializer(products, many=True)
        return Response(serializer.data)
```

**Step-by-Step**:
1. Open the API view file: `<leader>ff`, navigate to view file
2. Set breakpoint: Place cursor in view function, press `<leader>bb`
3. Start debug server: Press `<leader>dc`, select "🌐 DJANGO: Run Server"
4. Make API request:
   - **Using REST client**: Create `.rest` file:
     ```http
     POST http://localhost:8000/api/products/
     Content-Type: application/json
     
     {
       "name": "New Product",
       "price": 99.99
     }
     ```
     Place cursor on `POST` line, press `<leader>rg`
   - **Or use external tool**: Postman, curl, or browser
5. When breakpoint hits:
   - **Inspect request data**: 
     - Press `<leader>di` on `request.data` to see POST/PUT data
     - In REPL (`<leader>dr`), type `request.data` to see full payload
   - **Check query params**: In REPL, type `request.query_params`
   - **Inspect serializer**: Press `<leader>di` on `serializer`
   - **Check validation errors**: In REPL, type `serializer.errors` if invalid
   - **Step through logic**: Use `<leader>dj` or `<leader>dk`
6. View response: Continue execution (`<leader>dc`), check REST client output
7. Terminate: Press `<leader>dt` when done

**Debugging Serializers**:
1. Set breakpoint in serializer's `validate()` or `create()` method
2. Make API request that triggers serializer
3. Breakpoint will hit in serializer method

#### Advanced Debugging Techniques

**Conditional Breakpoints**:
1. Place cursor where you want breakpoint
2. Press `<leader>bc` (Conditional Breakpoint)
3. Enter condition: 
   - `user.is_staff == True`
   - `len(items) > 10`
   - `price > 100 and category == 'electronics'`
4. Breakpoint only triggers when condition is true

**Logpoints (Log Without Stopping)**:
1. Place cursor where you want logging
2. Press `<leader>bl` (Logpoint)
3. Enter log message with variable placeholders:
   - `User: {user.username}, Count: {count}`
   - `Processing item {item.id}: {item.name}`
4. Values are logged to console without stopping execution

**Using the Debug REPL**:
1. When breakpoint hits, press `<leader>dr` to open REPL
2. Test expressions in current context:
   ```python
   >>> user.email
   'test@example.com'
   >>> Product.objects.filter(price__gte=100).count()
   5
   >>> calculate_discount(100, 0.2)
   80.0
   ```
3. Modify variables (if mutable):
   ```python
   >>> items.append({'price': 30})
   ```
4. Test function calls before using in code

**Variable Inspection**:
- **Hover**: Hover over variable to see value and type
- **Detailed info**: Press `<leader>di` on variable for full details
- **All scopes**: Press `<leader>d?` to see all variables in current scope
- **Call stack**: Press `<leader>df` to see function call hierarchy

**Debug UI Panels**:
When debugging starts, DAP UI automatically opens with:
- **Left Panel**: Scopes, Stacks, Watches, Breakpoints
- **Right Panel**: REPL and Console
- Navigate panels: Use mouse or arrow keys
- Close UI: Press `q` in panel or `<leader>dt` to terminate

**Troubleshooting**:
- **Breakpoint not hitting**: 
  - Verify file is saved
  - Check you're using correct debug configuration
  - Ensure code path is actually executed
- **Variables not showing**: 
  - Use REPL to verify variable exists
  - Check variable is in current scope
- **Debugger not starting**:
  - Verify `debugpy` is installed: `pip install debugpy`
  - Check virtual environment is detected correctly
  - Verify Python path in debug configuration

## Python Development Examples

This section provides practical, step-by-step examples for common Python development tasks. These examples are designed for Python developers working with Django, Flask, or pure Python projects.

> **Note**: Keyboard shortcuts are included in examples for context. For a complete reference, see the [Plugin Shortcuts Cheatsheet](#plugin-shortcuts-cheatsheet).

### Quick Start: Common Python Tasks

#### Creating a New Python File with Type Hints

1. Open a new file: `<leader>ff` (Telescope Find Files), then type the new filename (e.g., `utils.py`)
2. Start writing a function:
   ```python
   def calculate_total(items):
       return sum(item.price for item in items)
   ```
3. Add type hints: Place cursor on `items` parameter, press `<leader>gg` (hover) to see type suggestions, then add:
   ```python
   from typing import List
   
   def calculate_total(items: List[dict]) -> float:
       return sum(item['price'] for item in items)
   ```
4. Format the file: `<leader>f` (auto-formats on save, or manually format)
5. Check for errors: `<leader>e` to see any diagnostics

#### Running a Python Script

1. Open your Python file (e.g., `main.py`)
2. Open terminal: `<leader>tt`
3. Run the script: `python main.py` or `python3 main.py`
4. Exit terminal mode: `<Esc>`

#### Checking and Fixing Imports

1. Open a Python file with import issues
2. View diagnostics: `<leader>e` or `[d`/`]d` to navigate errors
3. Fix missing imports: Place cursor on the undefined symbol, press `<leader>ga` (Code Actions)
4. Select "Import [module]" from the code actions menu
5. The import will be automatically added at the top of the file

#### Finding Python Functions and Classes

1. Find a function in current file: `<leader>fo` (Find symbols in document)
2. Find a function across project: `<leader>fg` (Live grep), type `def function_name`
3. Find a class: `<leader>fg`, type `class ClassName`
4. Find methods in current file: `<leader>fm` (Find methods)

### Testing Workflows

#### Running a Specific Pytest Test

1. Open your test file (e.g., `test_models.py`)
2. Navigate to the test function you want to run
3. Set a breakpoint (optional): Place cursor on line, press `<leader>bb`
4. Open terminal: `<leader>tt`
5. Run the specific test: `pytest test_models.py::TestUserModel::test_create_user -v`
6. Or run all tests in file: `pytest test_models.py -v`

#### Debugging a Failing Test

1. Open the test file with the failing test
2. Set a breakpoint at the start of the test: Place cursor, press `<leader>bb`
3. Start debugging: `<leader>dc` (Debug Control)
4. Select "🧪 PYTEST: Run Current Test" or "🧪 DJANGO: Run Tests"
5. When breakpoint hits:
   - Inspect variables: Place cursor on variable, press `<leader>di` (Variable Info)
   - Step through code: `<leader>dj` (Step Over), `<leader>dk` (Step Into)
   - View call stack: `<leader>df` (List Frames)
   - Use REPL: `<leader>dr` (Toggle REPL) to test expressions
6. Continue execution: `<leader>dc`
7. Terminate when done: `<leader>dt`

#### Generating Tests for a Function

1. Open the Python file with the function you want to test
2. Visually select the function (e.g., `V` to start visual mode, then `}` to select function)
3. Generate tests: `<leader>at` (CodeCompanion Generate Tests)
4. Review the generated test code
5. Copy the test: `gy` (yank last code block from chat) if using chat, or copy directly
6. Create or open test file: `<leader>ff`, type `test_*.py`
7. Paste and save the test

#### Running All Tests with Coverage

1. Open terminal: `<leader>tt`
2. Run with coverage: `pytest --cov=. --cov-report=html`
3. View coverage report: Open `htmlcov/index.html` in browser, or use `<leader>ff` to find the file

### Code Quality Workflows

#### Fixing Linting Errors with Ruff

1. Open a Python file with linting issues
2. View all diagnostics: `<leader>q` (List all diagnostics)
3. Navigate to errors: `[d` (Previous), `]d` (Next)
4. Auto-fix issues: Place cursor on error, press `<leader>ga` (Code Actions)
5. Select "Fix all auto-fixable problems" if available
6. Or format file: `<leader>f` (Ruff will auto-format on save)

#### Formatting Python Code

1. Format current file: `<leader>f` (formats on save automatically)
2. Format selected code: Visual select code, then `<leader>f`
3. Check formatting: View diagnostics with `<leader>e` - Ruff will show formatting issues

#### Fixing Type Errors

1. Open file with type errors (shown with diagnostic icons)
2. View type error: Place cursor on error, press `<leader>e` (Show diagnostic)
3. Get suggestions: Press `<leader>ga` (Code Actions) for quick fixes
4. Add type hints: Use hover (`<leader>gg`) to see expected types, then add annotations
5. Example fix:
   ```python
   # Before (error)
   def process(data):
       return data.upper()
   
   # After (fixed)
   def process(data: str) -> str:
       return data.upper()
   ```

#### Adding Missing Imports

**Automatic Import Resolution (Recommended):**
1. Place cursor on undefined symbol (e.g., `Account` or `datetime`)
2. Press `<leader>ai` (Auto-import)
3. **If multiple import options exist**: A picker menu will appear showing all possible imports
   - Use arrow keys or `<C-j>`/`<C-k>` to navigate
   - Press `<Enter>` to select the desired import
   - Press `<Esc>` to cancel
4. **If only one option**: The import is added automatically
5. The import statement is inserted at the top of the file

**Using Code Actions (Alternative):**
1. Use undefined symbol (e.g., `datetime`)
2. View error: `<leader>e` shows "undefined name 'datetime'"
3. Quick fix: Press `<leader>ga` (Code Actions)
4. **If multiple import options**: A code action menu appears with all import options
   - Type the number of the desired import and press `<Enter>`
   - Or click with mouse
5. Select "Import datetime" - import is added automatically

**Manual Import:**
- Type `from datetime import datetime`, use completion (`<C-Space>`) for suggestions

**Choosing Between Multiple Import Options:**

When multiple import paths exist (e.g., `Account` model in multiple Django apps):
- **Method 1 (Auto-import)**: `<leader>ai` shows a picker menu - select the desired import path
- **Method 2 (Code Actions)**: `<leader>ga` shows numbered options - type the number to select
- **Method 3 (Manual)**: Use `<leader>gd` to go to definition first, see the file path, then add import manually

**Note:** When using `uv run nvim .`, the configuration automatically detects:
- `uv` virtual environment and configures Pyright to use it
- Django project structure and adds app paths to `extraPaths`
- This enables better import resolution and code actions for Django models

### Refactoring Workflows

#### Extracting a Function

1. Select the code block to extract (Visual mode: `V` then move cursor)
2. Open CodeCompanion chat: `<leader>ac`
3. Ask: "Extract this code into a function named `calculate_discount` with parameters for price and discount_rate"
4. Review suggested function, copy with `gy`
5. Create the function, replace original code with function call

#### Renaming a Function Across Files

1. Place cursor on function name
2. Rename: `<leader>lr` (Rename symbol)
3. Type new name, press Enter
4. Pyright will show preview of all occurrences
5. Confirm rename - all references across the project are updated

#### Moving Code to a New File

1. Select the code to move (Visual mode)
2. Cut: `d` (delete/cut in visual mode)
3. Create new file: `<leader>ff`, type new filename (e.g., `helpers.py`)
4. Paste: `p`
5. Add imports if needed: Use `<leader>ga` to fix import errors
6. Update original file: Add import statement for the moved code

#### Improving Function Signatures

1. Place cursor on function definition
2. Get suggestions: `<leader>gg` (Hover) to see function usage
3. Open chat: `<leader>ac`
4. Ask: "Improve this function signature with better type hints and parameter names"
5. Apply suggestions from CodeCompanion

### Django-Specific Workflows

#### Creating a New Django Model

1. Open or create `models.py` in your Django app
2. Write model definition:
   ```python
   class Product(models.Model):
       name = models.CharField(max_length=100)
       price = models.DecimalField(max_digits=10, decimal_places=2)
   ```
3. Get field suggestions: Type `models.` and use completion (`<C-Space>`)
4. Check for errors: `<leader>e` to see any model issues
5. Generate migration: Open terminal (`<leader>tt`), run `python manage.py makemigrations`
6. Apply migration: `python manage.py migrate`

#### Running and Debugging Migrations

1. Open terminal: `<leader>tt`
2. Create migrations: `python manage.py makemigrations`
3. Debug migration (if issues): Set breakpoint in migration file, use `<leader>dc` → "⚙️ DJANGO: Custom Command" → type `migrate`
4. Or run normally: `python manage.py migrate`

#### Testing a Django View

1. Open your view file (e.g., `views.py`)
2. Find the view function: `<leader>fo` (Find symbols) or `<leader>fm` (Find methods)
3. Set breakpoint in view: Place cursor, press `<leader>bb`
4. Start Django server in debug mode: `<leader>dc` → "🌐 DJANGO: Run Server"
5. Make request to trigger view (use REST client or browser)
6. When breakpoint hits:
   - Inspect `request` object: `<leader>di` on `request`
   - Check `request.POST` or `request.GET`: Use REPL (`<leader>dr`)
   - Step through view logic
7. Continue or terminate: `<leader>dc` or `<leader>dt`

#### Working with Django Admin

1. Open `admin.py` in your app
2. Register model: Use completion for `admin.site.register`
   ```python
   from django.contrib import admin
   from .models import Product
   
   @admin.register(Product)
   class ProductAdmin(admin.ModelAdmin):
       list_display = ['name', 'price']
   ```
3. Check for errors: `<leader>e`
4. Test admin: Start server (`<leader>dc` → "🌐 DJANGO: Run Server"), visit `/admin`

#### Working with Django ORM Queries

1. Open a view or management command file
2. Write ORM query:
   ```python
   products = Product.objects.filter(price__gte=100).select_related('category')
   ```
3. Optimize query: Select query, press `<leader>ac`, ask "Optimize this Django ORM query"
4. Check query in database: Use `<leader>db` to open database UI, write equivalent SQL
5. Test query performance: Use Django shell (`<leader>dc` → "🔮 DJANGO: Shell Plus")

### API Development Workflows

#### Creating a REST API Endpoint

1. Create or open `views.py` or `viewsets.py`
2. Write endpoint:
   ```python
   from rest_framework.decorators import api_view
   from rest_framework.response import Response
   
   @api_view(['GET'])
   def product_list(request):
       products = Product.objects.all()
       return Response([{'id': p.id, 'name': p.name} for p in products])
   ```
3. Add type hints: Use `<leader>gg` for suggestions
4. Format: `<leader>f`
5. Check for errors: `<leader>e`

#### Testing API Endpoints with REST Client

1. Create test file: `<leader>ff`, create `api_tests.rest`
2. Write API request:
   ```http
   GET http://localhost:8000/api/products/
   Content-Type: application/json
   ```
3. Execute request: Place cursor on `GET` line, press `<leader>rg`
4. View response: Opens in `_OUTPUT.json` buffer
5. Format JSON response: `<leader>xj` if needed
6. Debug if error: Set breakpoint in view, restart server with debugger

#### Debugging API Responses

1. Set breakpoint in API view: `<leader>bb`
2. Start debug server: `<leader>dc` → "🌐 DJANGO: Run Server"
3. Make API request: Use REST client (`<leader>rg`) or external tool
4. When breakpoint hits:
   - Inspect request data: `<leader>di` on `request.data`
   - Check query params: Use REPL (`<leader>dr`), type `request.query_params`
   - Step through response generation
5. View response: Continue execution, check REST client output

#### Working with JSON Data

1. Receive JSON in API: Response opens in `_OUTPUT.json`
2. Format JSON: `<leader>xj` (Format as JSON)
3. Copy JSON structure: Select JSON, use for creating serializers
4. Create serializer: Open `serializers.py`, use JSON structure as reference
5. Validate: Use CodeCompanion (`<leader>ac`) to ask "Create a DRF serializer for this JSON structure"

### Project Navigation for Python

#### Finding All Usages of a Function

1. Place cursor on function name
2. Find references: `<leader>gr` (Find references)
3. Telescope shows all files using this function
4. Navigate: Select file to jump to usage

#### Understanding Import Dependencies

1. Place cursor on import statement
2. Go to source: `<leader>gd` (Go to definition)
3. See what's exported: `<leader>fo` (Find symbols) in the imported file
4. Find where module is used: `<leader>gr` on the import

#### Navigating Django App Structure

1. Open file explorer: `<leader>ee` (NvimTree)
2. Navigate to Django project root
3. Find app: Use `<leader>ff` (Find files), type app name
4. Quick access to common files:
   - Models: `<leader>ff`, type `models.py`
   - Views: `<leader>ff`, type `views.py`
   - URLs: `<leader>ff`, type `urls.py`
   - Tests: `<leader>ff`, type `test*.py`

#### Finding Python Classes and Methods

1. Find class in current file: `<leader>fo` (Find symbols), filter by `class`
2. Find class across project: `<leader>fg` (Live grep), type `class ClassName`
3. Find methods: `<leader>fm` (Find methods) in current file
4. Navigate between methods: `]m` (Next method), `[m` (Previous method)

### Tips and Tricks for Python Development

#### Quick Productivity Shortcuts

- **Jump to error**: `]d` (next diagnostic) or `[d` (previous) to quickly navigate errors
- **Fix all auto-fixable**: `<leader>ga` then select "Fix all" when available
- **Format on save**: Enabled by default - just save with `<leader>ww`
- **Quick file switch**: `<leader>fb` (Find buffers) to switch between open Python files
- **Split and compare**: `<leader>sv` (vertical split) to compare two files side-by-side

#### Working with Virtual Environments

1. The debugger automatically detects virtual environments (`.venv`, `venv`, `env`)
2. For Poetry projects: Automatically uses `poetry env`
3. For pipenv: Uses `$VIRTUAL_ENV` if activated
4. Check Python path: In debugger config, it auto-detects the correct interpreter

#### Common Python Patterns

**Type Hints Workflow:**
1. Write function without types
2. Let Pyright infer types (hover with `<leader>gg`)
3. Add type hints based on suggestions
4. Fix type errors as they appear

**Import Management:**
1. Use undefined symbol → `<leader>ai` → Auto-import (recommended, uses LSP)
2. Or use code actions: `<leader>ga` → Select import action
3. Organize imports: Ruff auto-organizes on format
4. Remove unused: Ruff flags unused imports, `<leader>ga` to remove

**Automatic Project Detection:**
- When using `uv run nvim .`, the configuration automatically:
  - Detects `uv` virtual environment and configures Pyright
  - Detects Django projects and adds app paths to `extraPaths`
  - Sets `PYTHONPATH` correctly for import resolution
  - Enables import code actions for Django models

**Error Handling:**
1. Write code that might raise exception
2. Pyright shows potential issues
3. Use CodeCompanion: Select code, `<leader>af` (Fix code) for error handling suggestions

#### Debugging Tips

- **Conditional breakpoints**: `<leader>bc` to set breakpoint that only triggers on condition
- **Log points**: `<leader>bl` to log variable values without stopping
- **REPL for testing**: `<leader>dr` opens Python REPL in debug context - test expressions live
- **Variable inspection**: `<leader>di` on any variable to see its value and type

#### Code Review Workflow

1. Open file to review
2. Check for issues: `<leader>q` (List all diagnostics)
3. Explain complex code: Select code, `<leader>ae` (Explain)
4. Suggest improvements: Select code, `<leader>ac`, ask "Review this code and suggest improvements"
5. Generate tests: Select function, `<leader>at` (Generate tests)

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

### Homebrew Package Management

This repository includes scripts to export and import Homebrew packages for environment reproducibility.

#### Exporting Packages

To export all installed Homebrew packages to a `Brewfile`:

```bash
./scripts/brew-export.sh
```

Options:
- `--file FILE` - Specify custom output file (default: `Brewfile`)
- `--include-mas` - Include Mac App Store apps (requires `mas-cli`)
- `--help` - Show usage information

The script exports:
- All installed Homebrew formulas
- All installed Homebrew casks
- All installed Homebrew taps
- Optional: Mac App Store apps (if `--include-mas` is used)

#### Importing Packages

To install all packages from a `Brewfile`:

```bash
./scripts/brew-import.sh
```

Options:
- `--file FILE` - Specify custom input file (default: `Brewfile`)
- `--dry-run` - Show what would be installed without installing
- `--force` - Install packages even if already installed
- `--help` - Show usage information

#### Using the Brewfile Directly

You can also use Homebrew's built-in bundle commands:

```bash
# Install all packages from Brewfile
brew bundle install

# Check if all packages are installed
brew bundle check

# Update Brewfile with current packages
brew bundle dump --force
```

#### Best Practices

1. **Regular Updates**: Periodically update your `Brewfile` to reflect current packages:
   ```bash
   ./scripts/brew-export.sh
   ```

2. **Version Control**: The `Brewfile` is tracked in git by default. If you have user-specific packages, you can add `Brewfile` to `.gitignore`.

3. **New Machine Setup**: On a new machine, clone this repository and run:
   ```bash
   ./scripts/brew-import.sh
   ```

4. **Dry Run First**: Before importing, check what will be installed:
   ```bash
   ./scripts/brew-import.sh --dry-run
   ```

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

## Plugin Shortcuts Cheatsheet

> **Note**: This section replaces the previous "Key Mappings" section and provides a comprehensive reference for all plugin shortcuts.

Quick reference for the most commonly used shortcuts organized by plugin. All shortcuts use `<Space>` as the leader key.

> **Mode Indicators**: `n` = Normal mode, `v` = Visual mode, `i` = Insert mode, `t` = Terminal mode

### File Navigation

#### Telescope (Fuzzy Finder)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ff` | n | Find files (fuzzy search) |
| `<leader>fg` | n | Live grep (search text across files) |
| `<leader>fb` | n | Find buffers (switch between open files) |
| `<leader>fh` | n | Find help tags |
| `<leader>fr` | n | Find recent files |
| `<leader>fs` | n | Find in current buffer (fuzzy search) |
| `<leader>fo` | n | Find symbols in document (LSP) |
| `<leader>fi` | n | Find incoming calls (LSP) |
| `<leader>fm` | n | Find methods (Treesitter) |

**Telescope Navigation (when picker is open):**
- `<C-j>` / `<C-k>` - Navigate up/down
- `<Enter>` - Select item
- `<Esc>` - Close picker
- `<C-t>` - Open in new tab
- `<C-v>` - Open in vertical split
- `<C-x>` - Open in horizontal split

#### nvim-tree (File Explorer)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ee` | n | Toggle file explorer |
| `<leader>ef` | n | Find current file in explorer |
| `<leader>er` | n | Focus file explorer |

**nvim-tree Navigation (when explorer is open):**
- `o` / `<Enter>` - Open file or expand directory
- `a` - Add file/folder
- `d` - Delete file/folder
- `r` - Rename file/folder
- `x` - Cut file/folder
- `p` - Paste file/folder
- `y` - Copy file/folder
- `c` - Copy file/folder path
- `w` - Copy file/folder name
- `q` - Close explorer
- `R` - Refresh explorer
- `?` - Show help

### Code Editing

#### nvim-cmp (Code Completion)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<C-Space>` | i | Show completion suggestions |
| `<C-j>` | i | Next completion item |
| `<C-k>` | i | Previous completion item |
| `<Tab>` | i | Select next item or jump to next snippet placeholder |
| `<S-Tab>` | i | Select previous item or jump to previous snippet placeholder |
| `<C-b>` | i | Scroll documentation backward |
| `<C-f>` | i | Scroll documentation forward |
| `<Enter>` | i | Confirm selection (replaces text) |

**Completion Sources:**
- LSP suggestions (from Pyright, Ruff, etc.)
- Snippets (LuaSnip)
- Buffer text (words in current file)
- File paths

#### nvim-surround (Text Surrounding)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `sa{motion}{char}` | n | Add surrounding (e.g., `saiw"` surrounds word with quotes) |
| `sd{char}` | n | Delete surrounding (e.g., `sd"` removes quotes) |
| `sr{target}{replacement}` | n | Replace surrounding (e.g., `sr"'` changes quotes to single quotes) |
| `S{char}` | v | Add surrounding to visual selection |

**Common Surrounding Characters:**
- `"` - Double quotes
- `'` - Single quotes
- `` ` `` - Backticks
- `(` or `)` - Parentheses
- `[` or `]` - Square brackets
- `{` or `}` - Curly braces
- `t` - HTML/XML tags

#### nvim-autopairs (Auto-pairing)
Auto-pairs automatically closes brackets, parentheses, and quotes. No shortcuts needed - it works automatically in Insert mode.

**Features:**
- Automatically closes `()`, `[]`, `{}`, `""`, `''`, ` `` `
- Smart pairing (respects Treesitter syntax)
- Works with LSP completion

#### LuaSnip (Snippets)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<Tab>` | i | Jump to next snippet placeholder (when snippet is active) |
| `<S-Tab>` | i | Jump to previous snippet placeholder (when snippet is active) |

**Usage:**
- Type snippet trigger (e.g., `def` for Python function)
- Press `<Tab>` to expand snippet
- Use `<Tab>` to navigate between placeholders
- Snippets are loaded from friendly-snippets and can be customized

### LSP & Diagnostics

#### nvim-lspconfig (Language Server Protocol)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>gd` | n | Go to definition |
| `<leader>gD` | n | Go to declaration |
| `<leader>gi` | n | Go to implementation |
| `<leader>gr` | n | Find references |
| `<leader>gt` | n | Go to type definition |
| `<leader>gg` | n | Show hover documentation |
| `<leader>gs` | n | Show signature help |
| `<leader>lr` | n | Rename symbol |
| `<leader>ga` | n | Code actions (quick fixes, refactors) |
| `<leader>ai` | n | Auto-import symbol under cursor (nvim-lspimport) |
| `<C-i>` | i | Auto-import symbol under cursor (insert mode) |

#### Diagnostics
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>e` | n | Show diagnostic float (error/warning under cursor) |
| `<leader>q` | n | Open diagnostics in location list |
| `]d` | n | Next diagnostic |
| `[d` | n | Previous diagnostic |
| `<leader>gn` | n | Next diagnostic (alternative) |
| `<leader>gp` | n | Previous diagnostic (alternative) |

### Debugging

#### DAP (Debug Adapter Protocol)
**Breakpoints:**
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>bb` | n | Toggle breakpoint |
| `<leader>bc` | n | Set conditional breakpoint |
| `<leader>bl` | n | Set logpoint (log without stopping) |
| `<leader>br` | n | Clear all breakpoints |
| `<leader>ba` | n | List all breakpoints (Telescope) |

**Debug Session Control:**
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>dc` | n | Continue/Start debugging |
| `<leader>dj` | n | Step over |
| `<leader>dk` | n | Step into |
| `<leader>do` | n | Step out |
| `<leader>dl` | n | Run last debug configuration |
| `<leader>dt` | n | Terminate debug session |
| `<leader>dd` | n | Disconnect debugger |

**Debug Info & UI:**
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>di` | n | Show variable information (hover) |
| `<leader>d?` | n | Show scopes |
| `<leader>dr` | n | Toggle REPL (debug console) |
| `<leader>df` | n | List frames (call stack) |
| `<leader>dh` | n | List debug commands |
| `<leader>de` | n | List diagnostics (errors) |

**Django Debug Configurations:**
- `<leader>dc` → Select "🌐 DJANGO: Run Server" - Debug Django server
- `<leader>dc` → Select "🧪 DJANGO: Run Tests" - Debug Django tests
- `<leader>dc` → Select "🔮 DJANGO: Shell Plus" - Debug Django shell
- `<leader>dc` → Select "⚙️ DJANGO: Custom Command" - Debug custom management command

### AI Assistant

#### CodeCompanion
**Normal Mode:**
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>aa` | n | Open CodeCompanion actions menu |
| `<leader>ac` | n | Toggle CodeCompanion chat |
| `<leader>al` | n | Explain LSP error under cursor |
| `<leader>am` | n | Generate commit message (from staged changes) |

**Visual Mode:**
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>aa` | v | Open CodeCompanion actions menu |
| `<leader>ac` | v | Toggle chat with selected code |
| `<leader>ae` | v | Explain selected code |
| `<leader>af` | v | Fix selected code |
| `<leader>at` | v | Generate tests for selected code |
| `<leader>as` | v | Add selection to active chat |

**Chat Buffer Commands:**
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<Enter>` / `<C-s>` | n | Send message |
| `<C-c>` | n | Close chat |
| `q` | n | Stop current request |
| `gy` | n | Yank last code block from chat |
| `gd` | n | View chat content in debug format |

### Database & API

#### vim-dadbod (Database UI)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>db` | n | Toggle database UI |
| `<leader>dq` | n | Execute query (entire buffer) |
| `<leader>dq` | v | Execute selected query |

**Database UI Navigation (when UI is open):**
- `Enter` - Open table/view or execute query
- `s` - Open SQL buffer for connection
- `?` - Show help
- `R` - Refresh
- `d` - Delete connection (when on connection)

#### vim-rest-console (REST Client)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>rg` | n | Execute GET request |
| `<leader>rp` | n | Execute POST request |
| `<leader>ru` | n | Execute PUT request |
| `<leader>rd` | n | Execute DELETE request |
| `<leader>xr` | n | Execute request under cursor (any method) |
| `<leader>xj` | n | Format as JSON |

**Usage:**
- Create `.rest` or `.http` file
- Write HTTP request (e.g., `GET https://api.example.com/users`)
- Place cursor on request line and press shortcut
- Response opens in `_OUTPUT.json` buffer

### Code Quality

#### conform.nvim (Code Formatting)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>f` | n | Format current buffer |
| `<leader>f` | v | Format selected code |

**Formatters:**
- Python: `ruff` (formatting)
- Lua: `stylua`
- JavaScript/TypeScript: `prettierd`
- Auto-formats on save (configured per filetype)

#### nvim-lint (Code Linting)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ll` | n | Lint current buffer |
| `<leader>lf` | n | Auto-fix linting issues (Lua files with selene) |

**Linters:**
- Lua: `selene`
- Python: `ruff` (via LSP)
- Auto-lints on file save and buffer enter

### Git Integration

#### git-blame-nvim
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>gb` | n | Toggle git blame (shows author and commit info) |

**Usage:**
- Toggle blame to see commit info inline
- Shows author, date, and commit message for each line

### Syntax & Navigation

#### Treesitter
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<C-Space>` | n | Show highlight groups under cursor |
| `<leader>tp` | n | Toggle Treesitter playground |
| `]m` | n | Next method/function |
| `[m` | n | Previous method/function |

**Features:**
- Enhanced syntax highlighting
- Code folding based on syntax
- Better code navigation

### Utilities

#### auto-session (Session Management)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ss` | n | Search and load session (Telescope) |
| `<leader>sd` | n | Delete session (Telescope) |

**Features:**
- Automatically saves session on exit
- Automatically restores session on open
- Sessions are project-based (by directory)

#### vim-maximizer (Window Maximizing)
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>sm` | n | Toggle maximize current window |

**Usage:**
- Maximize window to focus on single file
- Toggle again to restore previous layout

### General Navigation & Windows

#### Window Management
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>sv` | n | Split window vertically |
| `<leader>sh` | n | Split window horizontally |
| `<leader>sx` | n | Close split window |
| `<leader>se` | n | Make splits equal size |
| `<leader>sw` | n | Move split to new tab |
| `<leader>sj` | n | Decrease window height |
| `<leader>sk` | n | Increase window height |
| `<leader>sl` | n | Increase window width |

#### Buffer Management
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>bn` | n | Next buffer |
| `<leader>bp` | n | Previous buffer |
| `<leader>bd` | n | Delete buffer |
| `<leader>fb` | n | Find buffers (Telescope) |

#### Tab Management
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>to` | n | New tab |
| `<leader>tx` | n | Close tab |
| `<leader>tn` | n | Next tab |
| `<leader>tb` | n | Previous tab |

#### Terminal
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>tt` | n | Open terminal |
| `<Esc>` | t | Exit terminal mode |

#### Code Folding
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>za` | n | Toggle fold |
| `<leader>zA` | n | Toggle all folds |
| `<leader>zo` | n | Open fold |
| `<leader>zc` | n | Close fold |
| `<leader>zR` | n | Open all folds |
| `<leader>zM` | n | Close all folds |

#### Quickfix List
| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>qo` | n | Open quickfix list |
| `<leader>qc` | n | Close quickfix list |
| `<leader>qn` | n | Next quickfix item |
| `<leader>qp` | n | Previous quickfix item |
| `<leader>qf` | n | First quickfix item |
| `<leader>ql` | n | Last quickfix item |

### File Operations

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ww` | n | Save file |
| `<leader>wq` | n | Save and quit |
| `<leader>qq` | n | Quit without saving |
| `gx` | n | Open URL under cursor |

### Search & Replace

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>S` | n | Replace word under cursor (interactive) |
| `<leader>S` | v | Replace visual selection (interactive) |
| `n` | n | Next search result (centers cursor) |
| `N` | n | Previous search result (centers cursor) |
| `*` | n | Search word under cursor (centers cursor) |

This configuration is built for productive Python/Django development with quick access to common tasks. All key mappings are logically organized around the space key as leader.

