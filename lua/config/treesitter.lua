local M = {}

local ENSURE_INSTALLED = {
  "lua",
  "python",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "http",
  "css",
  "json",
  "markdown",
  "markdown_inline",
  "bash",
  "vim",
  "go",
  "rust",
  "ruby",
  "toml",
  "yaml",
  "requirements",
  "dockerfile",
  "make",
}

local MAX_HIGHLIGHT_FILESIZE = 1024 * 1024
local NO_TS_INDENT = { python = true }

local function too_big(buf)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  return ok and stats and stats.size > MAX_HIGHLIGHT_FILESIZE
end

local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  if not NO_TS_INDENT[lang] then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local function on_filetype(args)
  local ts = require("nvim-treesitter")
  local lang = vim.treesitter.language.get_lang(args.match)
  if not lang or too_big(args.buf) then
    return
  end
  if vim.list_contains(ts.get_installed(), lang) then
    attach(args.buf, lang)
  elseif vim.list_contains(ts.get_available(), lang) then
    -- auto_install replacement: the main branch dropped that option
    ts.install(lang):await(function()
      vim.schedule(function()
        attach(args.buf, lang)
      end)
    end)
  end
end

local function map_textobject(lhs, capture)
  vim.keymap.set({ "x", "o" }, lhs, function()
    require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
  end, { desc = "treesitter " .. capture })
end

function M.setup()
  require("nvim-treesitter").install(ENSURE_INSTALLED)
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
    callback = on_filetype,
  })
end

function M.setup_textobjects()
  require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })
  map_textobject("af", "@function.outer")
  map_textobject("if", "@function.inner")
  map_textobject("ac", "@class.outer")
  map_textobject("ic", "@class.inner")
end

return M
