local M = {}

local ns = vim.api.nvim_create_namespace("cloak")
local group = vim.api.nvim_create_augroup("Cloak", { clear = true })

-- matched on the tail of the path, so "dir/.env.local" hits ".env.*"
M.patterns = { ".env", ".env.*", "*.env", ".envrc" }

local hidden = true

-- KEY=value, optional "export ", optional spaces around "="; comment lines never match
local function value_start(line)
  local _, e = line:find("^%s*export%s+[%w_.-]+%s*=%s*")
  if not e then
    _, e = line:find("^%s*[%w_.-]+%s*=%s*")
  end
  return e
end

function M.render(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if not hidden then
    return
  end
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local start = value_start(line)
    if start and start < #line then
      vim.api.nvim_buf_set_extmark(buf, ns, row - 1, start, {
        end_col = #line,
        virt_text = { { string.rep("*", vim.fn.strdisplaywidth(line:sub(start + 1))), "Comment" } },
        virt_text_pos = "overlay",
        hl_mode = "replace",
      })
    end
  end
end

function M.is_secret_file(path)
  local name = vim.fs.basename(path)
  for _, glob in ipairs(M.patterns) do
    if vim.glob.to_lpeg(glob):match(name) then
      return true
    end
  end
  return false
end

function M.toggle()
  hidden = not hidden
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].cloaked then
      M.render(buf)
    end
  end
  vim.notify("cloak: values " .. (hidden and "hidden" or "visible"))
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = M.patterns,
    callback = function(args)
      vim.b[args.buf].cloaked = true
      M.render(args.buf)
    end,
  })
end

return M
