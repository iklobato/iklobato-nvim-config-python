-- default terraformls on_attach calls vim.lsp.codelens.enable(), missing before 0.12
if vim.lsp.codelens.enable == nil then
  vim.lsp.config("terraformls", {
    on_attach = function() end,
  })
end
