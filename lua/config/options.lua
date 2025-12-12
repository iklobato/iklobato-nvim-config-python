local opt = vim.opt

-- Session Management - optimized for faster session restore
-- Removed expensive options: 'blank' (empty buffers), 'help' (help windows), 'terminal' (terminal state)
-- Kept essential: buffers, curdir, folds, tabpages, winsize, winpos, localoptions, resize
opt.sessionoptions = "buffers,curdir,folds,tabpages,winsize,winpos,localoptions,resize"

-- Line Numbers
opt.relativenumber = false
opt.number = true

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
vim.bo.softtabstop = 2

-- Line Wrapping
opt.wrap = false

-- Search Settings
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Cursor Line - conditionally enabled for performance
-- Disabled by default, enabled only when cursor is idle
opt.cursorline = false

-- Enable cursorline only when not moving fast (performance optimization)
local cursorline_timer = nil
local function enable_cursorline()
  if cursorline_timer then
    cursorline_timer:stop()
    cursorline_timer:close()
  end
  
  -- Disable cursorline immediately on movement
  opt.cursorline = false
  
  -- Re-enable after a short delay (when cursor is idle)
  cursorline_timer = vim.loop.new_timer()
  cursorline_timer:start(300, 0, function()
    vim.schedule(function()
      opt.cursorline = true
      if cursorline_timer then
        cursorline_timer:close()
        cursorline_timer = nil
      end
    end)
  end)
end

-- Create autocommand group for cursorline optimization
local cursorline_group = vim.api.nvim_create_augroup('CursorlineOptimization', { clear = true })

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'WinEnter' }, {
  group = cursorline_group,
  callback = enable_cursorline,
})

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  group = cursorline_group,
  callback = function()
    opt.cursorline = false -- Disable during insert mode for performance
  end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  group = cursorline_group,
  callback = function()
    -- Re-enable after leaving insert mode
    vim.defer_fn(function()
      opt.cursorline = true
    end, 100)
  end,
})

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
vim.diagnostic.config {
  float = { border = "rounded" }, -- add border to diagnostic popups
}

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split Windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of keyword
opt.iskeyword:append("-")

-- Disable the mouse while in nvim
opt.mouse = ""

-- Folding
opt.foldlevel = 20
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()" -- Utilize Treesitter folds

-- Custom VIM options
-- These keymaps are already defined in keymaps.lua, removing duplicate definitions

-- Quality of Life configurations
opt.scrolloff = 5                  -- Reduced from 8 for better performance
opt.sidescrolloff = 5              -- Reduced from 8 for better performance
opt.timeoutlen = 200               -- Faster key sequence completion (reduced from 300ms)
opt.updatetime = 30                -- Faster cursor updates (reduced from 50ms for better responsiveness)

-- Optimize cursor rendering for maximum speed
-- Block cursor in normal mode, beam in insert mode, no blinking
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
  .. ",sm:block-blinkwait175-blinkoff150-blinkon175"

-- Disable swap files globally
vim.opt.swapfile = false

-- Disable netrw (using nvim-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

