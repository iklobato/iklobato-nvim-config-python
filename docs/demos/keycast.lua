-- Live keycast overlay for demo recordings. NOT part of the config: a tape loads
-- it with `nvim -c 'luafile .keycast-demo.lua'`. Shows the raw keys as they are
-- pressed, in a bordered box pinned bottom-center, fading after a short idle.

vim.api.nvim_set_hl(0, "KeycastBar", { fg = "#0B0B0C", bg = "#F5A623", bold = true })
vim.api.nvim_set_hl(0, "KeycastBorder", { fg = "#F5A623", bg = "#F5A623" })

local state = { buf = nil, win = nil, text = "", timer = nil }

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
  state.text = ""
end

local function centered(s, width)
  local w = vim.fn.strdisplaywidth(s)
  local left = math.max(0, math.floor((width - w) / 2))
  return string.rep(" ", left) .. s .. string.rep(" ", math.max(0, width - w - left))
end

local function show()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    state.buf = vim.api.nvim_create_buf(false, true)
  end
  local keys = state.text
  local width = math.max(20, vim.fn.strdisplaywidth(keys) + 6)
  local blank = string.rep(" ", width)
  -- three rows (pad / keys / pad) for a taller, more legible box
  local lines = { blank, centered(keys, width), blank }
  local cfg = {
    relative = "editor",
    anchor = "SW",
    row = vim.o.lines - 4,
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    width = width,
    height = 3,
    style = "minimal",
    focusable = false,
    noautocmd = true,
    zindex = 300,
    border = "rounded",
  }
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_config(state.win, cfg)
  else
    state.win = vim.api.nvim_open_win(state.buf, false, cfg)
    vim.wo[state.win].winhl = "Normal:KeycastBar,FloatBorder:KeycastBorder"
  end
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
end

local function bump()
  if state.timer then
    state.timer:stop()
  end
  state.timer = vim.defer_fn(close, 1800)
end

vim.on_key(function(key, typed)
  local raw = (typed ~= nil and typed ~= "") and typed or key
  if raw == nil or raw == "" then
    return
  end
  local s = vim.fn.keytrans(raw)
  if s == "" or s:match("Mouse") or s:match("ScrollWheel") then
    return
  end
  vim.schedule(function()
    state.text = state.text .. s
    while vim.fn.strdisplaywidth(state.text) > 24 do
      state.text = vim.fn.strcharpart(state.text, 1)
    end
    show()
    bump()
  end)
end)
