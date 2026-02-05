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

-- Tabline: show filename (tail) per tab
local function tabline_build()
  local cur, parts = vim.api.nvim_get_current_tabpage(), {}
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local buf = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
    local path = vim.api.nvim_buf_get_name(buf)
    local name = (path == "" or path == nil) and "[No Name]" or vim.fn.fnamemodify(path, ":t")
    name = (string.gsub(name, "%%", "%%%%"))
    parts[#parts + 1] = ("%s%%%dT %s %%X"):format(tab == cur and "%#TabLineSel#" or "%#TabLine#", i, name)
  end
  parts[#parts + 1] = "%#TabLineFill#%T"
  return table.concat(parts, "")
end
_G.tabline_build = tabline_build
vim.opt.tabline = "%!v:lua.tabline_build()"
