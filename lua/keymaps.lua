local map = vim.keymap.set

-- File operations
map("n", "<leader>ww", ":w<CR>", { desc = "Save file" })
map("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
map("n", "<leader>qq", ":q!<CR>", { desc = "Quit without saving" })

-- Search
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Git
map("n", "<leader>gb", "<cmd>GitBlameToggle<CR>", { desc = "Toggle git blame" })

-- File explorer
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
map("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })

-- Replace
map("n", "<leader>S", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word" })
map("v", "<leader>S", "y:%s/<C-r>\"/<C-r>\"/gI<Left><Left><Left>", { desc = "Replace selection" })

-- Formatting
map("n", "<leader>f", function()
  require("conform").format({ lsp_fallback = false })
end, { desc = "Format" })
map("v", "<leader>f", function()
  require("conform").format({ lsp_fallback = false })
end, { desc = "Format selection" })

-- Debugging
map("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Debug continue" })
map("n", "<leader>bb", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
map("n", "<leader>bc", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>bl", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Logpoint" })
map("n", "<leader>br", function()
  require("dap").clear_breakpoints()
end, { desc = "Clear breakpoints" })
map("n", "<leader>ba", function()
  require("telescope").extensions.dap.list_breakpoints()
end, { desc = "List breakpoints" })
map("n", "<leader>dj", function()
  require("dap").step_over()
end, { desc = "Debug step over" })
map("n", "<leader>dk", function()
  require("dap").step_into()
end, { desc = "Debug step into" })
map("n", "<leader>do", function()
  require("dap").step_out()
end, { desc = "Debug step out" })
map("n", "<leader>dl", function()
  require("dap").run_last()
end, { desc = "Run last" })
map("n", "<leader>dt", function()
  require("dap").terminate()
end, { desc = "Terminate debug session" })
map("n", "<leader>dd", function()
  require("dap").disconnect()
end, { desc = "Disconnect debugger" })
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug UI" })

-- Avante
map("n", "<leader>aa", "<cmd>AvanteToggle<CR>", { desc = "Avante" })
