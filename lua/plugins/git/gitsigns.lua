-- Git Signs - Show diff indicators in sign column
return {
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy',
  config = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      -- Signs appear in sign column (left of line numbers)
      -- signcolumn in gitsigns expects boolean (true/false), not string
      -- The actual sign column visibility is controlled by vim.opt.signcolumn in options.lua
      signcolumn = true,
      -- Ensure line numbers remain visible (they're configured in options.lua)
      -- Do not highlight changed lines
      linehl = false,
      -- Do not highlight changed numbers
      numhl = false,
      -- Watch for changes in git index
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      -- Attach to buffers automatically
      attach_to_untracked = false,
      current_line_blame = false, -- Disable inline blame (we have git-blame-nvim for that)
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
      },
    })
    
    -- Ensure line numbers and sign column remain visible after gitsigns setup
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.signcolumn = "yes" -- Ensure sign column is visible for both signs and line numbers
  end,
}
