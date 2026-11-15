local opt = vim.opt

opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.termguicolors = true

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true
opt.clipboard:append("unnamedplus")

opt.mouse = ""
opt.swapfile = false

opt.scrolloff = 8
opt.sidescrolloff = 8

opt.updatetime = 300
-- Keep 'timeout' on: with it off, maps that prefix longer ones block forever.
opt.timeoutlen = 300
opt.ttimeoutlen = 50
opt.redrawtime = 1500
-- ':200,/100,@50' cap history ('history' is 10000): a 185KB file read in ~11ms became 53KB in ~5.5ms.
-- Empty here so startup skips the read; VimEnter restores it and reads after the first frame.
local SHADA = "'100,<50,s10,h,:200,/100,@50"
opt.shada = ""
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      vim.o.shada = SHADA
      -- no bang: marks and v:oldfiles already set (a restored session) are kept
      vim.cmd.rshada()
    end)
  end,
})

opt.cursorline = true
opt.cursorcolumn = false
opt.hlsearch = true
opt.incsearch = true

vim.cmd("hi! link CurSearch Search")

opt.signcolumn = "yes"
opt.shortmess:append("c")
opt.pumheight = 10
opt.hidden = true
opt.autoread = false

-- one global rounded border for every float: hover, signature, rename, code action
opt.winborder = "rounded"
-- hide the ~ past end of buffer; cleaner fold gutter and diff fill
opt.fillchars = {
  eob = " ",
  fold = " ",
  diff = "╱",
  foldopen = "▾",
  foldclose = "▸",
  foldsep = " ",
}
-- slight depth on the completion menu; floats stay opaque so hover text keeps contrast
opt.pumblend = 10
opt.winblend = 0
-- blink the insert-mode bar so the cursor is easy to find after a mode switch
opt.guicursor = "n-v-c:block,i-ci-ve:ver25-blinkwait300-blinkon200-blinkoff150,r-cr-o:hor20"

-- auto-session needs 'localoptions' to restore filetype-local settings
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
