-- Feature suite: ./tests/run.sh (exits 0 when every check passes)

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
  {
    "option: lazyredraw off",
    function()
      expect(vim.o.lazyredraw == false, "lazyredraw is on")
    end,
  },
  {
    "option: updatetime 300",
    function()
      expect(vim.o.updatetime == 300, "updatetime=" .. vim.o.updatetime)
    end,
  },
  {
    "option: system clipboard",
    function()
      expect(vim.o.clipboard:find("unnamedplus"), "clipboard=" .. vim.o.clipboard)
    end,
  },
  {
    "option: leader is space",
    function()
      expect(vim.g.mapleader == " ", "mapleader=" .. tostring(vim.g.mapleader))
    end,
  },
  {
    "option: mapping timeout on",
    function()
      expect(vim.o.timeout == true, "timeout is off, prefix maps will hang")
    end,
  },
  {
    "option: sessionoptions has localoptions",
    function()
      expect(vim.o.sessionoptions:find("localoptions"), "sessionoptions=" .. vim.o.sessionoptions)
    end,
  },
  {
    "option: no hardcoded db connection",
    function()
      expect(vim.g.dbs == nil, "vim.g.dbs is set: " .. vim.inspect(vim.g.dbs))
    end,
  },

  -- read the global keymap table: nvim-tree's buffer-local W would shadow maparg()
  {
    "keymap: W swap is not recursive",
    function()
      local w
      for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
        if m.lhs == "W" then
          w = m
        end
      end
      expect(w ~= nil, "no global W map")
      expect(w.rhs == "B", "W maps to " .. tostring(w.rhs))
      expect(w.noremap == 1, "W is recursive, it will raise E223")
    end,
  },
  -- assert on <Tab>: maparg treats <C-i> as distinct, so querying it proves nothing
  {
    "keymap: <C-i> free for jumplist",
    function()
      for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
        expect(m.lhs ~= "<Tab>", "normal-mode <Tab> is mapped, that takes <C-i> with it")
      end
    end,
  },

  -- must run BEFORE the dap checks below require("dap")
  {
    "dap: commands registered before dap loads",
    function()
      expect(package.loaded["dap"] == nil, "dap already loaded, this check proves nothing here")
      for _, cmd in ipairs({
        "DapNew",
        "DapContinue",
        "DapToggleBreakpoint",
        "DapTerminate",
        "DapEval",
        "DapShowLog",
      }) do
        expect(vim.fn.exists(":" .. cmd) == 2, ":" .. cmd .. " not defined")
      end
    end,
  },

  -- must also run before dap: dap pulls mason in on purpose
  {
    "perf: opening a file starts LSP without loading mason",
    function()
      edit("perf.py", { "x = 1" })
      vim.wait(2000, function()
        return package.loaded["lsp"] ~= nil
      end)
      expect(package.loaded["lsp"] ~= nil, "lua/lsp never loaded on BufReadPost")
      expect(package.loaded["mason"] == nil, "mason loaded at file open, it should wait for :Mason")
      expect(vim.lsp.is_enabled("pyright"), "pyright not enabled")
    end,
  },
  {
    "perf: mason binaries reachable on PATH without mason loaded",
    function()
      expect(vim.fn.executable("pyright-langserver") == 1, "mason/bin is not on PATH")
    end,
  },

  {
    "ui: terminal-noir colorscheme",
    function()
      expect(vim.g.colors_name == "terminal-noir", "colorscheme=" .. tostring(vim.g.colors_name))
    end,
  },
  { "ui: bufferline", loads("bufferline") },
  { "ui: lualine", loads("lualine") },
  { "ui: gitsigns", loads("gitsigns") },
  { "ui: nvim-tree", loads("nvim-tree") },
  { "ui: nvim-tree command", command_exists("NvimTreeToggle") },
  { "ui: indent guides (ibl)", loads("ibl") },
  { "ui: treesitter-context", loads("treesitter-context") },

  {
    "treesitter: python parser",
    function()
      expect(pcall(vim.treesitter.language.add, "python"), "python parser missing")
    end,
  },
  {
    "treesitter: lua parser",
    function()
      expect(pcall(vim.treesitter.language.add, "lua"), "lua parser missing")
    end,
  },
  { "completion: blink.cmp", loads("blink.cmp") },
  {
    "formatting: conform",
    function()
      local conform = require("conform")
      expect(next(conform.formatters_by_ft) ~= nil, "no formatters configured")
    end,
  },
  { "telescope", loads("telescope") },
  { "telescope command", command_exists("Telescope") },

  { "keymap: file explorer <leader>ee", keymap_exists(" ee") },
  { "keymap: maximize split <leader>sm", keymap_exists(" sm") },
  { "keymap: markdown preview <leader>mp", keymap_exists(" mp") },
  { "keymap: debug pytest <leader>dp", keymap_exists(" dp") },
  { "keymap: breakpoint <leader>bb", keymap_exists(" bb") },
  { "keymap: python exception stops <leader>be", keymap_exists(" be") },
  { "keymap: debug ui <leader>du", keymap_exists(" du") },

  { "dadbod-ui stub command", command_exists("DBUI") },
  {
    "keymap: <leader>sm maximizes the split, then restores it",
    function()
      vim.cmd("only")
      vim.cmd("vsplit")
      local win = vim.api.nvim_get_current_win()
      local before = vim.api.nvim_win_get_width(win)
      local function press()
        vim.api.nvim_feedkeys(vim.keycode("<Space>sm"), "mx", false)
      end
      press()
      local maximized = vim.api.nvim_win_get_width(win)
      press()
      local restored = vim.api.nvim_win_get_width(win)
      vim.cmd("only")
      expect(maximized > before, ("width %d -> %d, not maximized"):format(before, maximized))
      expect(restored == before, ("width %d after restore, want %d"):format(restored, before))
    end,
  },
  { "mason command", command_exists("Mason") },
  { "session: auto-session", loads("auto-session") },

  {
    "markdown-preview: loads on md file",
    function()
      edit("t.md", { "# t" })
      vim.wait(2000, function()
        return vim.fn.exists(":MarkdownPreview") == 2
      end)
      expect(vim.fn.exists(":MarkdownPreview") == 2, ":MarkdownPreview not defined")
    end,
  },
  {
    "markdown-preview: random port",
    function()
      expect(vim.g.mkdp_port == "", "mkdp_port=" .. tostring(vim.g.mkdp_port))
    end,
  },

  {
    "git blame: gitsigns inline blame on, 1000ms delay",
    function()
      local config = require("gitsigns.config").config
      expect(config.current_line_blame == true, "current_line_blame is off")
      local delay = config.current_line_blame_opts.delay
      expect(delay == 1000, "blame delay=" .. tostring(delay))
    end,
  },

  {
    "bigfile: a >1MB file skips treesitter, LSP and indent guides",
    function()
      local line = string.rep("x = 1  # padding", 4)
      local lines = {}
      for i = 1, 20000 do
        lines[i] = line
      end
      -- indented lines, so ibl would draw guides if it attached
      lines[2] = "def f():"
      lines[3] = "    return 1"
      edit("big.py", lines)
      local buf = vim.api.nvim_get_current_buf()
      expect(vim.bo[buf].filetype == "bigfile", "filetype=" .. vim.bo[buf].filetype)
      -- pyright attaches in ~1-2s on a small file; give it 5s to (wrongly) attach
      vim.wait(5000, function()
        return false
      end)
      expect(vim.bo[buf].syntax == "python", "regex syntax=" .. vim.bo[buf].syntax)
      expect(vim.treesitter.highlighter.active[buf] == nil, "treesitter highlights the big file")
      local guides = vim.api.nvim_buf_get_extmarks(
        buf,
        vim.api.nvim_create_namespace("indent_blankline"),
        0,
        -1,
        {}
      )
      expect(#guides == 0, #guides .. " indent guides drawn on the big file")
      local names = vim.tbl_map(function(c)
        return c.name
      end, vim.lsp.get_clients({ bufnr = buf }))
      expect(#names == 0, "LSP still attached to the big file: " .. table.concat(names, ", "))
    end,
  },

  {
    "kulala: loads on http file",
    function()
      edit("t.http", { "GET https://example.com" })
      local plugin = require("lazy.core.config").plugins["kulala.nvim"]
      vim.wait(2000, function()
        return plugin._.loaded ~= nil
      end)
      expect(plugin._.loaded, "kulala plugin not loaded for .http")
      expect(pcall(require, "kulala"), "kulala module failed to load")
    end,
  },

  {
    "lazy: luarocks disabled",
    function()
      expect(require("lazy.core.config").options.rocks.enabled == false, "rocks still enabled")
    end,
  },

  {
    "autocmd: jq as json formatprg",
    function()
      edit("t.json", { "{}" })
      expect(vim.bo.formatprg == "jq .", "formatprg=" .. vim.bo.formatprg)
    end,
  },

  {
    "dap: python adapter + 4 configs",
    function()
      local dap = require("dap")
      expect(dap.adapters.python, "no python adapter")
      expect(#dap.configurations.python == 4, "#configs=" .. #dap.configurations.python)
    end,
  },
  {
    "dap: go adapter + 4 configs",
    function()
      local dap = require("dap")
      expect(dap.adapters.delve, "no delve adapter")
      expect(#dap.configurations.go == 4, "#configs=" .. #dap.configurations.go)
    end,
  },
  {
    "dap: node + chrome adapters, 5 configs on every js/ts filetype",
    function()
      local dap = require("dap")
      expect(dap.adapters["pwa-node"], "no pwa-node adapter")
      expect(dap.adapters["pwa-chrome"], "no pwa-chrome adapter")
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        local configs = dap.configurations[ft]
        expect(configs and #configs == 5, ft .. " configs=" .. tostring(configs and #configs))
      end
    end,
  },
  {
    "dap: dapui auto-opens (listeners registered)",
    function()
      local dap = require("dap")
      expect(dap.listeners.after.event_initialized["dapui"], "dapui listener missing")
      expect(package.loaded["dapui"], "dapui not loaded with dap")
    end,
  },
  {
    "dap: mason-nvim-dap loaded with dap",
    function()
      expect(package.loaded["mason-nvim-dap"], "mason-nvim-dap not loaded")
    end,
  },
  {
    "dap: debugpy installed via mason",
    function()
      local python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      expect(vim.fn.executable(python) == 1, python .. " not executable")
    end,
  },
  {
    "dap: delve installed via mason",
    function()
      local dlv = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv"
      expect(vim.fn.executable(dlv) == 1, dlv .. " not executable")
    end,
  },
  {
    "dap: js-debug-adapter installed via mason",
    function()
      local server = vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      expect(vim.fn.filereadable(server) == 1, server .. " not readable")
    end,
  },
  {
    "dap: mason registry populated when dap pulls mason in",
    function()
      local registry = require("mason-registry")
      expect(registry.has_package("delve"), "mason registry is empty")
    end,
  },
  {
    "dap: shared python_path helper",
    function()
      local path = require("config.dap").python_path()
      expect(type(path) == "string" and path ~= "", "python_path()=" .. tostring(path))
    end,
  },

  {
    "lsp: pyright binary installed",
    function()
      local bin = vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver"
      expect(vim.fn.executable(bin) == 1, bin .. " not executable")
    end,
  },
  {
    "lsp: client attaches to python file",
    function()
      edit("t.py", { "x = 1" })
      vim.cmd.doautocmd("FileType")
      vim.wait(15000, function()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end)
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      expect(#clients > 0, "no LSP client attached after 15s")
    end,
  },
  {
    "lsp: on_attach maps land on the buffer",
    function()
      local want = { gd = true, gr = true, gi = true, [" rn"] = true, [" ca"] = true }
      for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        want[m.lhs] = nil
      end
      expect(next(want) == nil, "missing maps: " .. table.concat(vim.tbl_keys(want), ", "))
    end,
  },
  -- fresh nvim, file opened after VimEnter (a CLI arg never broke), cwd scratch: no session
  {
    "lsp: server settings survive a late open",
    function()
      local target = scratch .. "/late.py"
      local result = scratch .. "/late.json"
      local probe = scratch .. "/probe.lua"
      vim.fn.writefile({ "x = 1" }, target)
      vim.fn.writefile({
        "vim.defer_fn(function()",
        ("  vim.cmd('edit %s')"):format(target),
        "  vim.wait(25000, function() return #vim.lsp.get_clients({ bufnr = 0 }) >= 2 end, 100)",
        "  local out = {}",
        "  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do",
        "    out[c.name] = { settings = c.settings, init_options = c.config.init_options }",
        "  end",
        ("  vim.fn.writefile({ vim.json.encode(out) }, %q)"):format(result),
        "  vim.cmd('qa!')",
        "end, 1000)",
      }, probe)

      vim.fn.system({
        "sh",
        "-c",
        ("cd %s && timeout 60 nvim --headless -c 'luafile %s'"):format(scratch, probe),
      })
      expect(vim.fn.filereadable(result) == 1, "late-open probe wrote nothing")

      local got = vim.json.decode(vim.fn.readfile(result)[1])
      expect(got.pyright ~= nil, "pyright did not attach on a late open")
      local mode = vim.tbl_get(got, "pyright", "settings", "python", "analysis", "diagnosticMode")
      expect(mode == "openFilesOnly", "pyright diagnosticMode=" .. tostring(mode))
      expect(got.ruff ~= nil, "ruff did not attach on a late open")
      local len = vim.tbl_get(got, "ruff", "init_options", "settings", "lineLength")
      expect(len == 88, "ruff lineLength=" .. tostring(len))
    end,
  },
  {
    "lsp: only the allowlisted servers are enabled",
    function()
      local seen, enabled = {}, {}
      for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        if not seen[name] then
          seen[name] = true
          if vim.lsp.is_enabled(name) then
            table.insert(enabled, name)
          end
        end
      end
      local allowlist = require("lsp").SERVERS
      expect(type(allowlist) == "table", "lua/lsp SERVERS is not an allowlist")
      -- containment, not equality: only allowlisted AND installed servers get enabled
      local allowed = {}
      for _, name in ipairs(allowlist) do
        allowed[name] = true
      end
      local outside = {}
      for _, name in ipairs(enabled) do
        if not allowed[name] then
          table.insert(outside, name)
        end
      end
      expect(
        #outside == 0,
        "servers enabled outside the allowlist: " .. table.concat(outside, ", ")
      )
    end,
  },
  -- a fresh nvim records every vim.keymap.set the config itself makes, then each one
  -- must be named by a behaviour check in the tmux suites (deep/*.sh, e2e.sh)
  {
    "coverage: every keymap the config defines has a behaviour test",
    function()
      local root = vim.fn.getcwd()
      local result = scratch .. "/maps.json"
      local pre = scratch .. "/maps_pre.lua"
      local post = scratch .. "/maps_post.lua"
      vim.fn.writefile({
        "local set, maps = vim.keymap.set, {}",
        "_G.__recorded_maps = maps",
        "vim.keymap.set = function(mode, lhs, rhs, opts)",
        "  local src = debug.getinfo(2, 'S').source",
        ("  if src:find(%q, 1, true) then"):format(root .. "/lua/"),
        "    for _, m in ipairs(type(mode) == 'table' and mode or { mode }) do",
        "      maps[m .. ' ' .. lhs] = src:gsub('^@.*/lua/', 'lua/')",
        "    end",
        "  end",
        "  return set(mode, lhs, rhs, opts)",
        "end",
      }, pre)
      vim.fn.writefile({
        "vim.defer_fn(function()",
        -- LspAttach maps only exist once a server attaches; fire the config's handler
        "  require('lsp')",
        "  vim.api.nvim_exec_autocmds('LspAttach', { group = 'UserLspAttach', buffer = 0,",
        "    data = { client_id = 0 } })",
        ("  vim.fn.writefile({ vim.json.encode(_G.__recorded_maps) }, %q)"):format(result),
        "  vim.cmd('qa!')",
        "end, 1500)",
      }, post)
      local target = scratch .. "/maps.py"
      vim.fn.writefile({ "x = 1" }, target)
      vim.fn.system({
        "sh",
        "-c",
        ("cd %s && timeout 60 nvim --headless --cmd 'luafile %s' -c 'luafile %s' %s"):format(
          scratch,
          pre,
          post,
          target
        ),
      })
      expect(vim.fn.filereadable(result) == 1, "keymap probe wrote nothing")
      local maps = vim.json.decode(vim.fn.readfile(result)[1])
      expect(vim.tbl_count(maps) >= 50, "probe saw only " .. vim.tbl_count(maps) .. " maps")

      local names = {}
      local files = vim.fn.glob(root .. "/tests/deep/*.sh", false, true)
      table.insert(files, root .. "/tests/e2e.sh")
      for _, file in ipairs(files) do
        local text = table.concat(vim.fn.readfile(file), "\n")
        for _, helper in ipairs({ "wait_lexpr", "wait_screen", "ok", "bad" }) do
          for name in text:gmatch("%f[%w_]" .. helper .. ' "([^"]+)"') do
            table.insert(names, " " .. name .. " ")
          end
        end
      end

      local function plain(s)
        return (s:gsub("%p", "%%%0"))
      end
      -- operator-pending objects show up as "daf"; visual ones as "vaf"
      local function covered(mode, lhs)
        local textobject = not lhs:find("^<")
        for _, name in ipairs(names) do
          if mode == "o" and name:find("[ ][dcy]" .. plain(lhs) .. "[ ,]") then
            return true
          elseif mode == "x" and textobject and name:find("[ ]v" .. plain(lhs) .. "[ ,]") then
            return true
          elseif
            mode == "x"
            and not textobject
            and name:find("[ ]" .. plain(lhs) .. "[ ,]")
            and (name:find("visual") or name:find("selection"))
          then
            return true
          elseif mode == "n" and name:find("[ ]" .. plain(lhs) .. "[ ,]") then
            return true
          end
        end
        return false
      end

      local missing = {}
      for key, src in pairs(maps) do
        local mode, lhs = key:match("^(%S+) (.+)$")
        if not covered(mode, lhs) then
          table.insert(missing, key .. " (" .. src .. ")")
        end
      end
      table.sort(missing)
      expect(#missing == 0, "keymaps with no behaviour test: " .. table.concat(missing, "; "))
    end,
  },
  {
    "treesitter: function textobject is mapped",
    function()
      expect(vim.fn.maparg("af", "o") ~= "", "no operator-pending map for af")
      expect(vim.fn.maparg("if", "o") ~= "", "no operator-pending map for if")
    end,
  },
  {
    "treesitter: html script injects tsx, not javascript",
    function()
      edit("t.html", { "<style>a{}</style>", "<script>const x = () => <b/>;</script>" })
      local langs = {}
      local parser = vim.treesitter.get_parser(0, "html")
      parser:parse(true)
      parser:for_each_tree(function(_, tree)
        langs[tree:lang()] = true
      end)
      expect(langs.tsx, "tsx not injected: " .. table.concat(vim.tbl_keys(langs), ", "))
      expect(not langs.javascript, "javascript still injected alongside tsx")
    end,
  },
  {
    "treesitter: html typed script parses and highlights",
    function()
      edit("typed.html", { '<script type="text/javascript">let a = 1</script>' })
      local ok, err = pcall(function()
        vim.treesitter.get_parser(0, "html"):parse(true)
      end)
      expect(ok, tostring(err))
      expect(
        vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()],
        "highlighter not attached"
      )
    end,
  },
  {
    "formatting: every mason-provided formatter is installed",
    function()
      local conform = require("conform")
      -- clang-format comes from the system, not mason: a fresh machine may lack it
      local seen, missing = { clang_format = true }, {}
      for _, formatters in pairs(conform.formatters_by_ft) do
        for _, name in ipairs(formatters) do
          if not seen[name] then
            seen[name] = true
            if not conform.get_formatter_info(name, 0).available then
              table.insert(missing, name)
            end
          end
        end
      end
      expect(#missing == 0, "not installed: " .. table.concat(missing, ", "))
    end,
  },
  {
    "autocmd: single *.dbout handler",
    function()
      -- load dadbod-ui or the count is vacuous; scope to UserUi, its own autocmds are fine
      require("lazy").load({ plugins = { "vim-dadbod-ui" } })
      local found = vim.api.nvim_get_autocmds({ group = "UserUi", pattern = "*.dbout" })
      expect(#found == 1, #found .. " autocmds in UserUi for *.dbout")
    end,
  },
  {
    "session: dead buffers are dropped before saving",
    function()
      local gone = scratch .. "/deleted.txt"
      vim.fn.writefile({ "x" }, gone)
      local doomed = vim.fn.bufadd(gone)
      vim.fn.bufload(doomed)
      vim.bo[doomed].buflisted = true
      local kept = vim.fn.bufadd(scratch .. "/t.py")
      vim.bo[kept].buflisted = true
      vim.fn.delete(gone)

      require("config.session").drop_missing_buffers()

      expect(not vim.api.nvim_buf_is_valid(doomed), "buffer for a deleted file survived")
      expect(vim.api.nvim_buf_is_valid(kept), "buffer for an existing file was dropped")
    end,
  },
  {
    "nvim-tree: root follows the global cwd only",
    function()
      local opts = require("lazy.core.config").plugins["nvim-tree.lua"].opts
      expect(opts.sync_root_with_cwd == true, "sync_root_with_cwd is off")
      expect(opts.respect_buf_cwd ~= true, "respect_buf_cwd is on, an lcd can hijack the root")
    end,
  },
  {
    "reload: clean buffer picks up an outside change with no prompt",
    function()
      edit("reload_clean.txt", { "old" })
      vim.fn.writefile({ "changed on disk" }, scratch .. "/reload_clean.txt")
      vim.cmd("checktime")
      expect(vim.fn.getline(1) == "changed on disk", "buffer still has: " .. vim.fn.getline(1))
    end,
  },
  {
    "reload: unsaved text is backed up to a file and undo brings it back",
    function()
      edit("reload_dirty.txt", { "old" })
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "my unsaved text" })
      vim.fn.writefile({ "changed on disk by someone" }, scratch .. "/reload_dirty.txt")
      vim.cmd("checktime")

      expect(
        vim.fn.getline(1) == "changed on disk by someone",
        "not reloaded: " .. vim.fn.getline(1)
      )
      local backups =
        vim.fn.glob(vim.fn.stdpath("state") .. "/unsaved/*reload_dirty.txt.*", false, true)
      expect(#backups == 1, "expected 1 backup, found " .. #backups)
      local saved = vim.fn.readfile(backups[1])
      vim.fn.delete(backups[1])
      expect(saved[1] == "my unsaved text", "backup holds: " .. tostring(saved[1]))
      vim.cmd("silent undo")
      expect(vim.fn.getline(1) == "my unsaved text", "undo gave: " .. vim.fn.getline(1))
    end,
  },
  {
    "reload: file deleted on disk keeps the buffer",
    function()
      edit("reload_deleted.txt", { "keep me" })
      vim.fn.delete(scratch .. "/reload_deleted.txt")
      vim.cmd("checktime")
      expect(vim.fn.getline(1) == "keep me", "buffer changed to: " .. vim.fn.getline(1))
    end,
  },
}

-- ONLY=<text> ./tests/run.sh runs just the checks whose name contains <text>
local only = vim.env.ONLY
local failed, ran = 0, 0
local out = {}
for _, c in ipairs(checks) do
  local name, fn = c[1], c[2]
  if not only or name:find(only, 1, true) then
    ran = ran + 1
    local ok, err = pcall(fn)
    if ok then
      table.insert(out, "PASS  " .. name)
    else
      failed = failed + 1
      table.insert(out, "FAIL  " .. name .. "  (" .. tostring(err) .. ")")
    end
  end
end
table.insert(out, "")
table.insert(out, string.format("%d/%d checks passed", ran - failed, ran))

io.stdout:write(table.concat(out, "\n") .. "\n")
vim.fn.delete(scratch, "rf")
if failed > 0 then
  vim.cmd("cq 1")
end
vim.cmd("qa!")
