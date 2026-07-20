-- Feature test suite for this nvim config.
-- Run: ./tests/run.sh  (or: nvim --headless "+luafile tests/features.lua")
-- Exits 0 when every check passes, 1 otherwise.

local function expect(cond, msg)
  if not cond then
    error(msg or "condition failed", 0)
  end
end

local function loads(mod)
  return function()
    local ok, err = pcall(require, mod)
    expect(ok, tostring(err))
  end
end

local function command_exists(cmd)
  return function()
    expect(vim.fn.exists(":" .. cmd) == 2, ":" .. cmd .. " not defined")
  end
end

local function keymap_exists(lhs)
  return function()
    expect(vim.fn.maparg(lhs, "n") ~= "", "no normal-mode map for " .. lhs)
  end
end

local scratch = vim.fn.tempname()
vim.fn.mkdir(scratch, "p")

local function edit(name, lines)
  local path = scratch .. "/" .. name
  vim.fn.writefile(lines or { "" }, path)
  vim.cmd.edit(path)
  vim.cmd.doautocmd("BufRead")
end

local checks = {
  -- core options
  { "option: lazyredraw off", function()
    expect(vim.o.lazyredraw == false, "lazyredraw is on")
  end },
  { "option: updatetime 300", function()
    expect(vim.o.updatetime == 300, "updatetime=" .. vim.o.updatetime)
  end },
  { "option: system clipboard", function()
    expect(vim.o.clipboard:find("unnamedplus"), "clipboard=" .. vim.o.clipboard)
  end },
  { "option: leader is space", function()
    expect(vim.g.mapleader == " ", "mapleader=" .. tostring(vim.g.mapleader))
  end },

  -- UI (PyCharm-style)
  { "ui: darcula-dark colorscheme", function()
    expect(vim.g.colors_name == "darcula-dark", "colorscheme=" .. tostring(vim.g.colors_name))
  end },
  { "ui: bufferline", loads("bufferline") },
  { "ui: lualine", loads("lualine") },
  { "ui: gitsigns", loads("gitsigns") },
  { "ui: nvim-tree", loads("nvim-tree") },
  { "ui: nvim-tree command", command_exists("NvimTreeToggle") },
  { "ui: indent guides (ibl)", loads("ibl") },
  { "ui: treesitter-context", loads("treesitter-context") },

  -- editing core
  { "treesitter: python parser", function()
    expect(pcall(vim.treesitter.language.add, "python"), "python parser missing")
  end },
  { "treesitter: lua parser", function()
    expect(pcall(vim.treesitter.language.add, "lua"), "lua parser missing")
  end },
  { "completion: blink.cmp", loads("blink.cmp") },
  { "formatting: conform", function()
    local conform = require("conform")
    expect(next(conform.formatters_by_ft) ~= nil, "no formatters configured")
  end },
  { "telescope", loads("telescope") },
  { "telescope command", command_exists("Telescope") },

  -- keymaps (one per category file)
  { "keymap: file explorer <leader>ee", keymap_exists(" ee") },
  { "keymap: maximize split <leader>sm", keymap_exists(" sm") },
  { "keymap: markdown preview <leader>mp", keymap_exists(" mp") },
  { "keymap: debug pytest <leader>dp", keymap_exists(" dp") },
  { "keymap: breakpoint <leader>bb", keymap_exists(" bb") },
  { "keymap: debug ui <leader>du", keymap_exists(" du") },

  -- lazy-loaded tools (stub commands must be registered)
  { "dadbod-ui stub command", command_exists("DBUI") },
  { "maximizer stub command", command_exists("MaximizerToggle") },
  { "mason command", command_exists("Mason") },
  { "session: auto-session", loads("auto-session") },

  -- markdown preview (the port-collision fix)
  { "markdown-preview: loads on md file", function()
    edit("t.md", { "# t" })
    vim.wait(2000, function()
      return vim.fn.exists(":MarkdownPreview") == 2
    end)
    expect(vim.fn.exists(":MarkdownPreview") == 2, ":MarkdownPreview not defined")
  end },
  { "markdown-preview: random port", function()
    expect(vim.g.mkdp_port == "", "mkdp_port=" .. tostring(vim.g.mkdp_port))
  end },

  -- git blame (delayed off the cursor path)
  { "git-blame: loaded with 1000ms delay", function()
    expect(vim.g.gitblame_delay == 1000, "gitblame_delay=" .. tostring(vim.g.gitblame_delay))
  end },

  -- copilot (InsertEnter-gated)
  { "copilot: loads on insert", function()
    vim.api.nvim_exec_autocmds("InsertEnter", {})
    vim.wait(2000, function()
      return vim.fn.exists(":Copilot") == 2
    end)
    expect(vim.fn.exists(":Copilot") == 2, ":Copilot not defined")
  end },

  -- kulala (http-file-gated)
  { "kulala: loads on http file", function()
    edit("t.http", { "GET https://example.com" })
    local plugin = require("lazy.core.config").plugins["kulala.nvim"]
    vim.wait(2000, function()
      return plugin._.loaded ~= nil
    end)
    expect(plugin._.loaded, "kulala plugin not loaded for .http")
    expect(pcall(require, "kulala"), "kulala module failed to load")
  end },

  -- luarocks is disabled: a rockspec build failure aborts the whole config
  { "lazy: luarocks disabled", function()
    expect(require("lazy.core.config").options.rocks.enabled == false, "rocks still enabled")
  end },

  -- autocmds
  { "autocmd: jq as json formatprg", function()
    edit("t.json", { "{}" })
    expect(vim.bo.formatprg == "jq .", "formatprg=" .. vim.bo.formatprg)
  end },
  { "autocmd: Taskfile detected as yaml", function()
    edit("Taskfile.yml", { "version: '3'" })
    expect(vim.bo.filetype == "yaml", "filetype=" .. vim.bo.filetype)
  end },

  -- DAP (the lazy-load ordering fixes)
  { "dap: python adapter + 3 configs", function()
    local dap = require("dap")
    expect(dap.adapters.python, "no python adapter")
    expect(#dap.configurations.python == 3, "#configs=" .. #dap.configurations.python)
  end },
  { "dap: dapui auto-opens (listeners registered)", function()
    local dap = require("dap")
    expect(dap.listeners.after.event_initialized["dapui"], "dapui listener missing")
    expect(package.loaded["dapui"], "dapui not loaded with dap")
  end },
  { "dap: mason-nvim-dap loaded with dap", function()
    expect(package.loaded["mason-nvim-dap"], "mason-nvim-dap not loaded")
  end },
  { "dap: debugpy installed via mason", function()
    local python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    expect(vim.fn.executable(python) == 1, python .. " not executable")
  end },
  { "dap: shared python_path helper", function()
    local path = require("config.dap").python_path()
    expect(type(path) == "string" and path ~= "", "python_path()=" .. tostring(path))
  end },

  -- LSP end to end: pyright attaches to a python buffer
  { "lsp: pyright binary installed", function()
    local bin = vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver"
    expect(vim.fn.executable(bin) == 1, bin .. " not executable")
  end },
  { "lsp: client attaches to python file", function()
    edit("t.py", { "x = 1" })
    vim.cmd.doautocmd("FileType")
    vim.wait(15000, function()
      return #vim.lsp.get_clients({ bufnr = 0 }) > 0
    end)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    expect(#clients > 0, "no LSP client attached after 15s")
  end },
}

local failed = 0
local out = {}
for _, c in ipairs(checks) do
  local name, fn = c[1], c[2]
  local ok, err = pcall(fn)
  if ok then
    table.insert(out, "PASS  " .. name)
  else
    failed = failed + 1
    table.insert(out, "FAIL  " .. name .. "  (" .. tostring(err) .. ")")
  end
end
table.insert(out, "")
table.insert(out, string.format("%d/%d checks passed", #checks - failed, #checks))

io.stdout:write(table.concat(out, "\n") .. "\n")
vim.fn.delete(scratch, "rf")
if failed > 0 then
  vim.cmd("cq 1")
end
vim.cmd("qa!")
