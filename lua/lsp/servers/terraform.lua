-- nvim-lspconfig's default terraformls on_attach calls vim.lsp.codelens.enable(),
-- which only exists on nvim 0.12+; neutralize it while running 0.11
if vim.lsp.codelens.enable == nil then
  vim.lsp.config("terraformls", {
    on_attach = function() end,
  })
end
