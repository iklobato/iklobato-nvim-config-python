local M = {}

-- Helper function to safely require a module
function M.safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify("Failed to load module: " .. module_name, vim.log.levels.WARN)
    return nil
  end
  return module
end

-- Helper function to load multiple modules
function M.load_modules(modules)
  local loaded = {}
  for _, module_name in ipairs(modules) do
    local module = M.safe_require(module_name)
    if module then
      table.insert(loaded, module)
    end
  end
  return loaded
end

return M