local group = vim.api.nvim_create_augroup("UserFiletypes", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})
