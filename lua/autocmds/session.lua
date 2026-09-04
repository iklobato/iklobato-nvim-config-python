-- Session management autocmds
local group = vim.api.nvim_create_augroup("UserSession", { clear = true })

-- Auto-open NvimTree if no file was specified and no session restored
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function(data)
    vim.defer_fn(function()
      local directory = vim.fn.isdirectory(data.file) == 1
      local bufname = vim.fn.bufname()
      local no_file = bufname == "" or bufname == nil
      local tab_count = #vim.api.nvim_list_tabpages()
      -- `nvim .` restores the cwd session AND leaves data.file a directory, so
      -- without this guard the tree opened on top of the restored buffers. Only
      -- open when nothing was restored, which is what the README promises.
      -- vim.g.auto_session_restored (set in lua/config/session.lua's
      -- post_restore_cmds) reflects whether a restore actually happened, unlike
      -- checking for a session FILE on disk: that file can exist while nothing
      -- was restored (headless runs skip restoring outright).
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
