-- Live keycast overlay for demo recordings. NOT part of the config: a tape loads
-- it with `nvim -c 'luafile .keycast-demo.lua'`. Shows the raw keys as they are
-- pressed, in a bordered box pinned bottom-center, fading after a short idle.
-- When the keys finish a mapping that has a `desc`, the box adds that name on a
-- second line, so a tutorial viewer reads "<Space>bc / Conditional breakpoint".

vim.api.nvim_set_hl(0, "KeycastBar", { fg = "#0B0B0C", bg = "#F5A623", bold = true })
vim.api.nvim_set_hl(0, "KeycastBorder", { fg = "#F5A623", bg = "#F5A623" })

-- longest lhs looked up: <leader> + 3 keys covers every mapping in lua/keymaps
local MAX_LHS_TOKENS = 4

local state = { buf = nil, win = nil, text = "", timer = nil, tokens = {}, desc = nil }

local function is_mapping_mode(mode)
  return mode:match("^[nvVxs\22]") ~= nil
end

-- on_key can hand over several keys at once ("<Space>ba" when typed fast)
local function split_keys(s)
  local out = {}
  while s ~= "" do
    local tok = s:match("^<[^<>]+>") or vim.fn.strcharpart(s, 0, 1)
    out[#out + 1] = tok
    s = s:sub(#tok + 1)
  end
  return out
end

local function mapping_desc(tokens, mode)
  for n = math.min(#tokens, MAX_LHS_TOKENS), 2, -1 do
    local lhs = table.concat(tokens, "", #tokens - n + 1)
    local map = vim.fn.maparg(lhs, mode:sub(1, 1), false, true)
    if map.desc and map.desc ~= "" then
      return map.desc
    end
  end
  return nil
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
  state.text = ""
  state.tokens = {}
  state.desc = nil
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
  local desc = state.desc or ""
  local width = math.max(20, vim.fn.strdisplaywidth(keys) + 6, vim.fn.strdisplaywidth(desc) + 6)
  local blank = string.rep(" ", width)
  -- pad / keys / [desc] / pad, for a taller, more legible box
  local lines = { blank, centered(keys, width) }
  if state.desc then
    lines[#lines + 1] = centered(desc, width)
  end
  lines[#lines + 1] = blank
  local cfg = {
    relative = "editor",
    anchor = "SW",
    row = vim.o.lines - 4,
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    width = width,
    height = #lines,
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
  -- a prompt (breakpoint condition, logpoint message) holds the screen in
  -- cmdline mode, which does not repaint floats on its own
  if vim.api.nvim_get_mode().mode == "c" then
    vim.cmd.redraw()
  end
end

local function bump()
  if state.timer then
    state.timer:stop()
  end
  state.timer = vim.defer_fn(close, 1800)
end

-- which-key replays a finished leader sequence as one internal key whose `typed`
-- is the whole sequence ("<Space>ba"), so it would show twice
local function is_replay(key, typed_keys)
  return vim.fn.keytrans(key):match("^<t_") ~= nil and #split_keys(typed_keys) > 1
end

vim.on_key(function(key, typed)
  -- keys a mapping sends (typed == "", e.g. the `zv` after a debug step) are not
  -- what the viewer pressed
  if typed == nil or typed == "" then
    return
  end
  local s = vim.fn.keytrans(typed)
  if s == "" or s:match("Mouse") or s:match("ScrollWheel") or is_replay(key, s) then
    return
  end
  -- the mode before this key is handled decides which mapping table it belongs to
  local mode = vim.api.nvim_get_mode().mode
  vim.schedule(function()
    if is_mapping_mode(mode) then
      for _, tok in ipairs(split_keys(s)) do
        table.insert(state.tokens, tok)
      end
      while #state.tokens > MAX_LHS_TOKENS do
        table.remove(state.tokens, 1)
      end
      state.desc = mapping_desc(state.tokens, mode) or state.desc
    else
      state.tokens = {}
    end
    state.text = state.text .. s
    while vim.fn.strdisplaywidth(state.text) > 24 do
      state.text = vim.fn.strcharpart(state.text, 1)
    end
    show()
    bump()
  end)
end)
