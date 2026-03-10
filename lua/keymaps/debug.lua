local map = vim.keymap.set

-- Debugging helper functions
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

-- Debug keymaps
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