-- ts_ls is left on its default JS/TS filetypes. It was previously also attached
-- to "html" for JSX in <script> tags, but typescript-language-server rejects any
-- document whose languageId is not js/ts ("Cannot open document ... (languageId:
-- html)"), so it logged an error on every .html open and answered nothing.
-- JSX-in-html highlighting comes from queries/html_tags/injections.scm, not the LSP.
vim.lsp.config("ts_ls", {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})
