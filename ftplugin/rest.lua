-- REST file specific settings (same as HTTP)
vim.opt_local.syntax = "on"
vim.opt_local.filetype = "http"

-- Load HTTP syntax highlighting
vim.cmd('runtime! syntax/http.vim')
vim.cmd('syntax enable')
