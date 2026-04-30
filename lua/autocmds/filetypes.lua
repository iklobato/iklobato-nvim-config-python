-- Filetype-specific autocmds

-- JSON formatting with jq
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})

-- Taskfile detection
vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "Taskfile.yml", "Taskfile.yaml", "taskfile.yml", "taskfile.yaml" },
  callback = function(args)
    vim.bo.filetype = "yaml"
  end,
})