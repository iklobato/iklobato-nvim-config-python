-- no "html": ts_ls rejects non-js/ts languageIds and errors on every .html open
vim.lsp.config("ts_ls", {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})
