-- Filetype-specific autocmds

-- Python: disable tree-sitter indent, use vim indent
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.b.ts_disable = true
  end,
})

-- JSON formatting with jq
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})

-- Markdown preview plugin loading
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local plugin_path = vim.fn.stdpath("data")
      .. "/lazy/markdown-preview.nvim/plugin/mkdp.vim"
    if vim.fn.filereadable(plugin_path) == 1 then
      vim.cmd("source " .. plugin_path)
    end
  end,
})