-- React/TypeScript LSP: also attach to html for React in <script> tags (e.g. index.html with JSX)
vim.lsp.config("ts_ls", {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
})