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

-- Taskfile detection
vim.api.nvim_create_autocmd("BufRead", {
  group = group,
  pattern = { "Taskfile.yml", "Taskfile.yaml", "taskfile.yml", "taskfile.yaml" },
  callback = function()
    vim.bo.filetype = "yaml"
  end,
})
