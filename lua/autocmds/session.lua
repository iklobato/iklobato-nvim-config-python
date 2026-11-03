local group = vim.api.nvim_create_augroup("UserSession", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function(data)
    vim.defer_fn(function()
      local directory = vim.fn.isdirectory(data.file) == 1
      local bufname = vim.fn.bufname()
      local no_file = bufname == "" or bufname == nil
      local tab_count = #vim.api.nvim_list_tabpages()
      local restored = vim.g.auto_session_restored
      -- `nvim .` always gets the tree; a plain `nvim` only when nothing was restored
      local should_open = directory or (no_file and tab_count <= 1 and not restored)
      if not should_open then
        return
      end
      local ok, api = pcall(require, "nvim-tree.api")
      if not ok then
        return
      end
      api.tree.open()
      -- after a restore the cursor goes back to the file; update_focused_file reveals it
      if restored then
        vim.cmd.wincmd("p")
      end
    end, 100)
  end,
})
