local M = {}

local JS_FILETYPES = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
local JS_SKIP_FILES = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" }
local NODE_INSPECT_PORT = 9229
local CHROME_DEBUG_PORT = 9222
local DEFAULT_DEV_SERVER_URL = "http://localhost:5173"

-- the frontend of a monorepo is not the directory nvim was opened in, and
-- chrome resolves every source map against webRoot
local function web_root()
  local package_json = vim.fs.find("package.json", {
    path = vim.fn.expand("%:p:h"),
    upward = true,
  })[1]
  if not package_json then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(package_json)
end

local function prompt_dev_server_url()
  local url = vim.fn.input("Dev server URL: ", DEFAULT_DEV_SERVER_URL)
  if url == "" then
    -- empty means the prompt was cancelled; chrome would open about:blank
    return require("dap").ABORT
  end
  return url
end

function M.python_path()
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  return "python3"
end

-- without this the adapters fall back to whatever happens to be on PATH, which
-- dies with "exited with 1" and never mentions the missing package
local function mason_path(package_name)
  local ok, mason_registry = pcall(require, "mason-registry")
  if
    not ok
    or not mason_registry.has_package(package_name)
    or not mason_registry.is_installed(package_name)
  then
    vim.notify(
      package_name .. " not installed - run :MasonInstall " .. package_name,
      vim.log.levels.ERROR
    )
    return nil
  end
  return mason_registry.get_package(package_name):get_install_path()
end

function M.setup()
  local dap = require("dap")
  local pick_process = require("dap.utils").pick_process
  dap.set_log_level("ERROR")

  local function debugpy_adapter()
    local path = mason_path("debugpy")
    if not path then
      return nil
    end
    if vim.fn.has("win32") == 1 then
      return path .. "\\venv\\Scripts\\python.exe"
    end
    return path .. "/venv/bin/python"
  end

  dap.adapters.python = function(cb, config)
    if config.request == "attach" then
      cb({
        type = "server",
        port = config.port or 5678,
        host = config.host or "127.0.0.1",
      })
      return
    end
    cb({
      type = "executable",
      command = debugpy_adapter() or M.python_path(),
      args = { "-m", "debugpy.adapter" },
      -- cold start of the mason debugpy venv exceeds the 4s default here
      options = { initialize_timeout_sec = 20 },
    })
  end

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = M.python_path,
    },
    {
      type = "python",
      request = "launch",
      name = "Django runserver",
      program = "${workspaceFolder}/manage.py",
      args = { "runserver", "--noreload" },
      django = true,
      pythonPath = M.python_path,
    },
    {
      type = "python",
      request = "launch",
      name = "Pytest file",
      module = "pytest",
      args = { "${file}" },
      pythonPath = M.python_path,
    },
  }

  dap.adapters.delve = function(cb, config)
    if config.mode == "remote" and config.request == "attach" then
      cb({
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or 38697,
      })
      return
    end
    local path = mason_path("delve")
    if not path then
      return
    end
    cb({
      type = "server",
      port = "${port}",
      executable = {
        command = path .. "/dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
        -- dlv compiles the program from its OWN working directory, not from
        -- the cwd in the launch request: without this it fails with "cannot
        -- find main module" whenever nvim was opened above the go module
        cwd = config.cwd,
      },
      -- dlv compiles the program before answering, which blows the 4s default
      -- on a cold go build cache and fires a bogus "adapter didn't respond"
      options = { initialize_timeout_sec = 20 },
    })
  end

  dap.configurations.go = {
    {
      type = "delve",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${fileDirname}",
    },
    {
      type = "delve",
      request = "launch",
      name = "Launch package",
      program = "${fileDirname}",
      cwd = "${fileDirname}",
    },
    {
      type = "delve",
      request = "launch",
      name = "Test package",
      mode = "test",
      program = "${fileDirname}",
      cwd = "${fileDirname}",
    },
    {
      type = "delve",
      request = "attach",
      name = "Attach to process",
      mode = "local",
      processId = pick_process,
    },
  }

  -- one vscode-js-debug server serves both the node and the chrome side
  local function js_debug_adapter(cb)
    local path = mason_path("js-debug-adapter")
    if not path then
      return
    end
    cb({
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      executable = {
        command = "node",
        args = { path .. "/js-debug/src/dapDebugServer.js", "${port}" },
      },
      -- a cold node start plus launching a browser goes past the 4s default
      options = { initialize_timeout_sec = 20 },
    })
  end

  dap.adapters["pwa-node"] = js_debug_adapter
  dap.adapters["pwa-chrome"] = js_debug_adapter

  local js_configurations = {
    {
      type = "pwa-node",
      request = "launch",
      -- .ts included: node 22.18+ strips types natively, no ts-node/tsx needed
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      skipFiles = JS_SKIP_FILES,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = pick_process,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      skipFiles = JS_SKIP_FILES,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to node port " .. NODE_INSPECT_PORT,
      address = "127.0.0.1",
      port = NODE_INSPECT_PORT,
      cwd = "${workspaceFolder}",
      restart = true,
      sourceMaps = true,
      skipFiles = JS_SKIP_FILES,
    },
    -- react/jsx lives in the browser, so the node adapter above can never stop
    -- inside a component: that is what the chrome side is for
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Launch Chrome on dev server",
      url = prompt_dev_server_url,
      webRoot = web_root,
      sourceMaps = true,
    },
    {
      type = "pwa-chrome",
      request = "attach",
      name = "Attach to Chrome port " .. CHROME_DEBUG_PORT,
      port = CHROME_DEBUG_PORT,
      webRoot = web_root,
      sourceMaps = true,
    },
  }

  for _, filetype in ipairs(JS_FILETYPES) do
    dap.configurations[filetype] = js_configurations
  end
end

return M
