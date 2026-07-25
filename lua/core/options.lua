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
-- Keep 'timeout' on: with it off, every map that is a prefix of a longer one
-- (<leader>e, <leader>f, gr) blocks forever instead of firing.
opt.timeoutlen = 300
opt.ttimeoutlen = 50
opt.redrawtime = 1500

opt.cursorline = false
opt.cursorcolumn = false
opt.hlsearch = true
opt.incsearch = true

vim.cmd("hi! link CurSearch Search")

opt.signcolumn = "yes"
opt.shortmess:append("c")
opt.pumheight = 10
opt.hidden = true
opt.autoread = false

-- auto-session needs 'localoptions' to restore filetype-local settings
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
