local map = vim.keymap.set

-- LSP navigation. Lives here, not in lua/lsp/, so it is bound at startup:
-- lua/lsp/init.lua only loads on the first buffer read.
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

-- File explorer
map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file" })

-- Windows and tabs
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
map("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Maximize split" })
map("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tp", ":tabp<CR>", { desc = "Previous tab" })

-- Buffers (the bufferline "tabs" at the top). Not on <Tab>: in a terminal that
-- is the same byte as <C-i>, so it would kill jumplist-forward.
map("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- File operations
map("n", "<leader>ww", ":w<CR>", { desc = "Save file" })
map("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
map("n", "<leader>qq", ":q!<CR>", { desc = "Quit without saving" })

-- Fast cursor movement. No remap: W<->B is a swap, and remapping it recursively
-- makes both keys fail with E223.
map("n", "H", "^", { desc = "Line start" })
map("n", "L", "$", { desc = "Line end" })
map("n", "W", "B", { desc = "Word back" })
map("n", "B", "W", { desc = "Word forward" })
map("n", "<leader>j", "gj", { desc = "Visual line down" })
map("n", "<leader>k", "gk", { desc = "Visual line up" })
