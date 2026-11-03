local map = vim.keymap.set

-- here, not in lua/lsp/, so it binds at startup: lsp/ loads on first buffer read
map("n", "<leader>gd", function()
  -- split only once a location came back, otherwise a miss leaves an orphan window
  vim.lsp.buf.definition({
    on_list = function(list)
      if vim.tbl_isempty(list.items) then
        return
      end
      vim.cmd("vsplit")
      vim.fn.setqflist({}, " ", list)
      vim.cmd("cfirst")
    end,
  })
end, { desc = "Go to definition (vsplit)" })

map("n", "<leader>gr", function()
  require("telescope.builtin").lsp_references({ show_line = false })
end, { desc = "References (Telescope)" })

map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file" })

map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>se", function()
  local cur_tab = vim.api.nvim_get_current_tabpage()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    vim.api.nvim_set_current_tabpage(tab)
    vim.cmd("wincmd =")
  end
  vim.api.nvim_set_current_tabpage(cur_tab)
end, { desc = "Equalize splits" })
-- native toggle (replaced vim-maximizer): winrestcmd() holds the layout per tab page
map("n", "<leader>sm", function()
  local restore = vim.t.maximize_restore
  if restore then
    vim.t.maximize_restore = nil
    vim.cmd(restore)
    return
  end
  vim.t.maximize_restore = vim.fn.winrestcmd()
  vim.cmd("wincmd _ | wincmd |")
end, { desc = "Maximize split" })
-- "tabs" are the buffers bufferline draws on top; tab pages keep the native gt/gT.
-- Not on <Tab>: in a terminal it is <C-i>, so it would kill jumplist-forward.
map("n", "<leader>to", "<cmd>enew<CR>", { desc = "New tab" })
map("n", "<leader>tn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous tab" })
map("n", "<leader>td", "<cmd>bdelete<CR>", { desc = "Close tab" })

map("n", "<leader>ww", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>wq", "<cmd>wq<CR>", { desc = "Save and quit" })
map("n", "<leader>qq", "<cmd>q!<CR>", { desc = "Quit without saving" })

-- No remap: W<->B is a swap, and a recursive map fails with E223.
map("n", "H", "^", { desc = "Line start" })
map("n", "L", "$", { desc = "Line end" })
map("n", "W", "B", { desc = "Word back" })
map("n", "B", "W", { desc = "Word forward" })
map("n", "<leader>j", "gj", { desc = "Visual line down" })
map("n", "<leader>k", "gk", { desc = "Visual line up" })
