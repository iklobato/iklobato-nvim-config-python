local M = {}

function M.setup()
  local dap = require("dap")
  dap.set_log_level("ERROR")

  local function debugpy_adapter()
    local ok, mason_registry = pcall(require, "mason-registry")
    if not ok then
      return nil
    end
    if not mason_registry.has_package("debugpy") then
      return nil
    end
    if not mason_registry.is_installed("debugpy") then
      return nil
    end
    local path = require("mason-core.installer.InstallLocation")
      .global()
      :package("debugpy")
    if vim.fn.has("win32") == 1 then
      return path .. "\\venv\\Scripts\\python.exe"
    end
    return path .. "/venv/bin/python"
  end

  local function python_path()
    if vim.env.VIRTUAL_ENV then
      return vim.env.VIRTUAL_ENV .. "/bin/python"
    end
    return "python3"
  end

  dap.adapters.python = function(cb, config)
    local adapter_python = debugpy_adapter()
    if config.request == "attach" then
      cb({
        type = "server",
        port = config.port or 5678,
        host = config.host or "127.0.0.1",
      })
    else
      cb({
        type = "executable",
        command = adapter_python or python_path(),
        args = { "-m", "debugpy.adapter" },
      })
    end
  end

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = python_path,
    },
    {
      type = "python",
      request = "launch",
      name = "Django runserver",
      program = "${workspaceFolder}/manage.py",
      args = { "runserver", "--noreload" },
      django = true,
      pythonPath = python_path,
    },
    {
      type = "python",
      request = "launch",
      name = "Pytest file",
      module = "pytest",
      args = { "${file}" },
      pythonPath = python_path,
    },
  }
end

return M