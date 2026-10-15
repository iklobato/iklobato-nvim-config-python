local group = vim.api.nvim_create_augroup("UserSession", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function(data)
    vim.defer_fn(function()
      local directory = vim.fn.isdirectory(data.file) == 1
      local bufname = vim.fn.bufname()
      local no_file = bufname == "" or bufname == nil
      local tab_count = #vim.api.nvim_list_tabpages()
      -- `nvim .` both restores a session and passes a dir; skip the tree if restored
      local should_open = (directory or no_file)
        and tab_count <= 1
        and not vim.g.auto_session_restored
      if should_open then
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.open()
        end
      end
    end, 100)
  end,
})
