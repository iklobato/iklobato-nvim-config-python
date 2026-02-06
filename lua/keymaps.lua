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
map("n", "<leader>fo", function()
  local w = vim.api.nvim_win_get_width(0)
  require("telescope.builtin").lsp_document_symbols({
    symbol_width = math.max(40, math.floor(w * 0.5)),
    symbol_type_width = math.max(8, math.floor(w * 0.15)), -- category column (Variable, Function, Class, ...)
  })
end, { desc = "Find symbols" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>gp", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "<leader>gn", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Git
map("n", "<leader>gb", "<cmd>GitBlameToggle<CR>", { desc = "Toggle git blame" })

-- File explorer
map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file" })
-- map("n", "<leader>er", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- Markdown preview
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Markdown preview" })
map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown preview stop" })

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
local function dap_pytest_python_path()
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  return "python3"
end

local function dap_run_pytest(selector)
  if selector == nil or selector == "" then
    return
  end
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == nil or file_path == "" then
    vim.notify("No buffer path", vim.log.levels.WARN)
    return
  end
  require("dap").run({
    type = "python",
    request = "launch",
    name = "Pytest: " .. selector,
    module = "pytest",
    args = { file_path .. "::" .. selector },
    pythonPath = dap_pytest_python_path,
  })
end

local function dap_pytest_selectors_from_lsp(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)
  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", { textDocument = { uri = uri } }, function(_, result)
    if result == nil or not vim.tbl_islist(result) then
      callback({})
      return
    end
    local selectors = {}
    local kind = vim.lsp.protocol.SymbolKind
    local function collect(symbols, class_name)
      for _, sym in ipairs(symbols) do
        local name = sym.name or ""
        local sym_kind = sym.kind or 0
        if class_name then
          if sym_kind == kind.Method and name:match("^test_") then
            table.insert(selectors, class_name .. "::" .. name)
          end
          if sym.children and #sym.children > 0 then
            collect(sym.children, class_name)
          end
        else
          if sym_kind == kind.Function and name:match("^test_") then
            table.insert(selectors, name)
          end
          if sym_kind == kind.Class and name:match("^Test") and sym.children and #sym.children > 0 then
            collect(sym.children, name)
          end
        end
      end
    end
    collect(result, nil)
    callback(selectors)
  end)
end

local function dap_pytest_picker()
  dap_pytest_selectors_from_lsp(function(selectors)
    local items = { { value = "__manual__", display = "Manual (type pytest target)..." } }
    for _, s in ipairs(selectors) do
      table.insert(items, { value = s, display = s })
    end
    vim.ui.select(items, {
      prompt = "Pytest target:",
      format_item = function(item)
        return item.display or item.value
      end,
    }, function(choice)
      if choice == nil then
        return
      end
      local selector
      if choice == "__manual__" then
        selector = vim.fn.input("Pytest target (e.g. test_foo or TestClass::test_method): ")
      else
        selector = choice
      end
      if selector ~= nil and selector ~= "" then
        dap_run_pytest(selector)
      end
    end)
  end)
end

map("n", "<leader>dp", dap_pytest_picker, { desc = "Debug pytest (picker)" })
map("n", "<leader>df", function()
  local word = vim.fn.expand("<cword>")
  dap_run_pytest(word)
end, { desc = "Debug pytest function under cursor" })
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

-- Database
map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "Toggle DB UI" })
map("n", "<leader>dq", "<cmd>DBUIExecuteQuery<CR>", { desc = "Execute query" })
map("v", "<leader>dq", ":DBUIExecuteQuery<CR>", { desc = "Execute selected query" })
