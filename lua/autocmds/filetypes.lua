-- Filetype-specific autocmds
local group = vim.api.nvim_create_augroup("UserFiletypes", { clear = true })

-- JSON formatting with jq
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})

-- Taskfile.yml/yaml already resolve to filetype yaml via nvim's built-in
-- filetype-by-extension table; no autocmd needed here.
