-- Session management autocmds

-- Auto-open NvimTree if no file was specified and no session restored
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    vim.defer_fn(function()
      local directory = vim.fn.isdirectory(data.file) == 1
      local bufname = vim.fn.bufname()
      local no_file = bufname == "" or bufname == nil
      local tab_count = #vim.api.nvim_list_tabpages()
      local should_open = (directory or no_file) and tab_count <= 1
      if should_open then
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.open()
        end
      end
    end, 500)
  end,
})