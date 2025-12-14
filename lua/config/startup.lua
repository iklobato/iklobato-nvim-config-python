-- Startup time profiling and optimization
-- Run :StartupTime to see startup profiling

local M = {}

-- Function to profile startup time
function M.profile_startup()
  local stats = require("lazy").stats()
  local ms = (math.floor(stats.startuptime * 100) / 100)
  
  local lines = { string.format("Neovim loaded in %.2fms", ms) }
  
  -- Show top slow plugins if available
  if stats.times and type(stats.times) == "table" then
    local plugins = {}
    for name, time in pairs(stats.times) do
      table.insert(plugins, { name = name, time = time })
    end
    
    table.sort(plugins, function(a, b) return a.time > b.time end)
    
    table.insert(lines, "")
    table.insert(lines, "Top slow plugins:")
    for i = 1, math.min(10, #plugins) do
      table.insert(lines, string.format("  %d. %s: %.2fms", i, plugins[i].name, plugins[i].time))
    end
  else
    table.insert(lines, string.format("Loaded %d plugins", stats.loaded or 0))
  end
  
  -- Print to message area
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Create command to check startup time
vim.api.nvim_create_user_command("StartupTime", M.profile_startup, {
  desc = "Show startup time and slow plugins",
})

return M
