-- Autocommands go here

-- Open nvim-tree when opening a directory
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(data)
    -- Check if we opened a directory (e.g., `nvim .` or `nvim /path/to/dir`)
    local directory = vim.fn.isdirectory(data.file) == 1
    
    -- Also check if no file was specified (empty buffer means we opened a directory)
    local bufname = vim.fn.bufname()
    local no_file = bufname == "" or bufname == nil
    
    if directory or no_file then
      -- Open nvim-tree after a short delay to ensure everything is loaded
      vim.defer_fn(function()
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.open()
        end
      end, 0)
    end
  end,
})
