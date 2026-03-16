-- Filetype-specific autocmds

-- JSON formatting with jq
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})