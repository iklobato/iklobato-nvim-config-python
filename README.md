# Neovim Configuration Guide

A modern Neovim configuration focused on productivity with extensive LSP integration, debugging capabilities, and efficient navigation features.

## Table of Contents
- [Key Mappings](#key-mappings)
  - [General](#general)
  - [Window Management](#window-management)
  - [File Navigation](#file-navigation)
  - [Code Navigation](#code-navigation)
  - [Git Integration](#git-integration)
  - [Debugging](#debugging)
  - [Terminal](#terminal)
- [Common Workflows](#common-workflows)

## Key Mappings

> Note: The leader key is set to `<Space>`

### General
- `<leader>wq` - Save and quit
- `<leader>ww` - Save file
- `<leader>qq` - Quit all windows
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
- `<leader>sh` - Decrease width

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

### Code Navigation
LSP:
- `<leader>gd` - Go to definition
- `<leader>gr` - Find references
- `<leader>gg` - Hover documentation
- `<leader>ga` - Code actions
- `<leader>rr` - Rename symbol
- `<leader>gf` - Format code

Diagnostics:
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>e` - Show diagnostic float

### Git Integration
- `<leader>gb` - Toggle git blame

### Debugging
- `<leader>bb` - Toggle breakpoint
- `<leader>dc` - Continue
- `<leader>dj` - Step over
- `<leader>dk` - Step into
- `<leader>do` - Step out
- `<leader>dt` - Terminate debug session

### Terminal
- `<leader>tt` - Open terminal
- `<Esc>` - Exit terminal mode (when in terminal)

## Common Workflows

### 1. Quick File Search and Edit
```
1. Press <leader>ff (find files)
2. Type part of the filename
3. Enter to select
4. Edit file
5. <leader>ww to save
```

### 2. Search and Replace Across Project
```
1. <leader>fg (live grep)
2. Type search term
3. Enter to see all occurrences
4. <leader>S to initialize replace for word under cursor
5. Type replacement
6. Enter to confirm
```

### 3. Code Navigation Flow
```
1. <leader>gd to go to definition
2. <C-o> to jump back
3. <leader>gr to find all references
4. <leader>gg to see documentation
```

### 4. Split Window Workflow
```
1. <leader>sv to create vertical split
2. <leader>ee to open file explorer
3. Navigate and select file
4. <leader>sm to maximize current window
5. <leader>sm again to restore split
```

### 5. Debug Session
```
1. <leader>bb to set breakpoint
2. <leader>dc to start/continue debugging
3. <leader>dj to step over
4. <leader>di to inspect variable under cursor
5. <leader>dt to terminate session
```

### 6. Git Workflow
```
1. <leader>gb to toggle git blame
2. Navigate blame information
3. <leader>fg to search for specific changes
4. <leader>gf to format changes
```

This configuration is built for productivity with quick access to common development workflows. The key mappings are organized around the space key as the leader, making it easy to remember and execute commands quickly.

