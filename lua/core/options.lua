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
vim.cmd("filetype plugin on")
vim.g.loaded_syntax_hl = 1

opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ttyfast = true
opt.lazyredraw = true
opt.updatetime = 300
opt.timeoutlen = 300
opt.redrawtime = 1500

opt.cursorline = false
opt.cursorcolumn = false
opt.hlsearch = true
opt.incsearch = true

vim.cmd('hi! link CurSearch Search')

opt.signcolumn = "yes"
opt.shortmess:append("c")
opt.pumheight = 10
opt.hidden = true
opt.autoread = false
