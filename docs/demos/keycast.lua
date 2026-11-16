-- Live keycast overlay for demo recordings. NOT part of the config: a tape loads
-- it with `nvim -c 'luafile .keycast-demo.lua'`. Shows the keys of the current
-- command as key caps (Space  b  c) in a box pinned bottom-right, and under them
-- what the command does: the mapping `desc`, or a name for Vim's own commands.
-- Each new command starts a clean box; text typed into a prompt (a search, a file
-- name, a breakpoint condition) joins the command that opened the prompt.

local NS = vim.api.nvim_create_namespace("keycast")
local BG = "#17171A"
local ACCENT = "#F5A623"
vim.api.nvim_set_hl(0, "KeycastWin", { fg = "#E8E8EA", bg = BG })
vim.api.nvim_set_hl(0, "KeycastBorder", { fg = ACCENT, bg = BG })
vim.api.nvim_set_hl(0, "KeycastCap", { fg = "#0B0B0C", bg = ACCENT, bold = true })
vim.api.nvim_set_hl(0, "KeycastText", { fg = ACCENT, bg = "#2C2C33", bold = true })
vim.api.nvim_set_hl(0, "KeycastDesc", { fg = "#FFFFFF", bg = BG, bold = true })

-- longest lhs looked up: <leader> + 3 keys covers every mapping in lua/keymaps
local MAX_LHS_TOKENS = 4
local MAX_CAPS = 6
local MAX_TEXT = 14 -- a typed text chip keeps its last characters
-- Fixed size, so the video tools know the box pixels: after a zoom the original
-- box is pasted back on top at the same place. Space, 2 letters, a 14-char chip and Enter fit in 46.
local BOX_WIDTH = 46
local BOX_HEIGHT = 5
local FADE_MS = 1800

local PRETTY = {
  ["<Space>"] = "Space",
  ["<CR>"] = "Enter",
  ["<Esc>"] = "Esc",
  ["<BS>"] = "Bksp",
  ["<Tab>"] = "Tab",
  ["<Up>"] = "Up",
  ["<Down>"] = "Down",
  ["<Left>"] = "Left",
  ["<Right>"] = "Right",
}

-- Vim's own commands are not mappings, so maparg has no desc for them: name the
-- ones the narrated chapters teach
local BUILTIN_DESC = {
  gg = "Top of file",
  G = "End of file",
  ["}"] = "Next block",
  ["{"] = "Previous block",
  j = "Down a line",
  k = "Up a line",
  w = "Next word",
  b = "Previous word",
  ["/"] = "Search in file",
  n = "Next match",
  N = "Previous match",
  ["<C-O>"] = "Jump back",
  ["<C-I>"] = "Jump forward",
  ciw = "Change word",
  dd = "Delete line",
  yy = "Copy line",
  p = "Paste",
  u = "Undo",
  ["<C-R>"] = "Redo",
}

local state =
  { buf = nil, win = nil, timer = nil, tokens = {}, caps = {}, desc = nil, done = false }

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

local function pretty(tok)
  if PRETTY[tok] then
    return PRETTY[tok]
  end
  local ctrl = tok:match("^<C%-(.)>$")
  if ctrl then
    return "Ctrl+" .. ctrl:upper()
  end
  return tok
end

local function describe(lhs, mode)
  local map = vim.fn.maparg(lhs, mode:sub(1, 1), false, true)
  -- which-key maps each prefix (g, z, <Space>) with desc "which-key-trigger":
  -- that is the start of a command, not a command
  if map.desc and map.desc ~= "" and map.desc ~= "which-key-trigger" then
    return map.desc
  end
  return BUILTIN_DESC[lhs]
end

-- The whole command first, then its tails (a stray key before it). A 1-key tail
-- only counts when it is the whole command: `<Space>b` is not `b` (word back).
local function command_desc(mode)
  local tokens = state.tokens
  local shortest = #tokens == 1 and 1 or 2
  for n = math.min(#tokens, MAX_LHS_TOKENS), shortest, -1 do
    local desc = describe(table.concat(tokens, "", #tokens - n + 1), mode)
    if desc then
      return desc
    end
  end
  return nil
end

local function reset()
  state.tokens, state.caps, state.desc, state.done = {}, {}, nil, false
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
  reset()
end

local function push_cap(text, kind)
  table.insert(state.caps, { text = text, kind = kind })
  while #state.caps > MAX_CAPS do
    table.remove(state.caps, 1)
  end
end

-- letters typed into a prompt grow one text chip; special keys stay key caps
-- keytrans names some plain characters: in typed text they are just characters
local TYPED_CHARS = { ["<Space>"] = " ", ["<lt>"] = "<", ["<Bslash>"] = "\\", ["<Bar>"] = "|" }

local function push_typed(tok)
  tok = TYPED_CHARS[tok] or tok
  local last = state.caps[#state.caps]
  if tok:match("^<.+>$") then
    push_cap(pretty(tok), "cap")
  elseif last and last.kind == "text" then
    last.text = vim.fn.strcharpart(
      last.text .. tok,
      math.max(0, vim.fn.strchars(last.text .. tok) - MAX_TEXT)
    )
  else
    push_cap(tok, "text")
  end
end

local function push_command_key(tok, mode)
  push_cap(pretty(tok), "cap")
  table.insert(state.tokens, tok)
  while #state.tokens > MAX_LHS_TOKENS do
    table.remove(state.tokens, 1)
  end
  local desc = command_desc(mode)
  if desc then
    state.desc, state.done = desc, true
  elseif tok == "<Esc>" then
    state.done = true
  end
end

local function add_keys(s, mode)
  local command = is_mapping_mode(mode)
  if command and state.done then
    reset()
  end
  for _, tok in ipairs(split_keys(s)) do
    if command then
      push_command_key(tok, mode)
    else
      push_typed(tok)
    end
  end
end

-- one line of caps: returns the text and the byte ranges to highlight
local function caps_line()
  local parts, marks, col = {}, {}, 0
  for i, cap in ipairs(state.caps) do
    -- a terminal cell is twice as tall as wide: 2 spaces around 1 letter look square
    local pad = vim.fn.strchars(cap.text) == 1 and "  " or " "
    local chunk = pad .. cap.text .. pad
    marks[#marks + 1] = { col, col + #chunk, cap.kind == "text" and "KeycastText" or "KeycastCap" }
    parts[#parts + 1] = chunk
    col = col + #chunk
    if i < #state.caps then
      parts[#parts + 1] = " "
      col = col + 1
    end
  end
  return table.concat(parts), marks
end

local function pad_left(s, width)
  return math.max(0, math.floor((width - vim.fn.strdisplaywidth(s)) / 2))
end

local function render(width)
  local caps, marks = caps_line()
  local desc = state.desc or ""
  local caps_left, desc_left = pad_left(caps, width), pad_left(desc, width)
  local blank = string.rep(" ", width)
  local lines =
    { blank, string.rep(" ", caps_left) .. caps, blank, string.rep(" ", desc_left) .. desc, blank }
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(state.buf, NS, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(
      state.buf,
      NS,
      1,
      caps_left + m[1],
      { end_col = caps_left + m[2], hl_group = m[3] }
    )
  end
  if state.desc then
    vim.api.nvim_buf_set_extmark(
      state.buf,
      NS,
      3,
      desc_left,
      { end_col = desc_left + #desc, hl_group = "KeycastDesc" }
    )
  end
end

local function show()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    state.buf = vim.api.nvim_create_buf(false, true)
  end
  render(BOX_WIDTH)
  -- bottom-right, above the statusline and the command line
  local cfg = {
    relative = "editor",
    anchor = "SE",
    row = vim.o.lines - 3,
    col = vim.o.columns - 2,
    width = BOX_WIDTH,
    height = BOX_HEIGHT,
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
    vim.wo[state.win].winhl = "Normal:KeycastWin,FloatBorder:KeycastBorder"
  end
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
  state.timer = vim.defer_fn(close, FADE_MS)
end

-- which-key replays a finished leader sequence as one internal key whose `typed`
-- is the whole sequence ("<Space>ba"), so it would show twice
local function is_replay(key, typed_keys)
  return vim.fn.keytrans(key):match("^<t_") ~= nil and #split_keys(typed_keys) > 1
end

-- For a plain prefix like `g`, which-key replays the finished keys one by one
-- (`gg` logged as <t_g>, g, then g, g again), each marked typed. A replay key
-- lands within a millisecond of the key before it; VHS types visible keys
-- 150 ms apart, so a key that fast after a which-key trigger is a replay.
local REPLAY_MS = 30
local replay = { armed = false, dropped = false, last_ns = 0 }

local function is_fast_replay(key)
  local now = vim.uv.hrtime()
  local fast = (now - replay.last_ns) / 1e6 < REPLAY_MS
  replay.last_ns = now
  if vim.fn.keytrans(key):match("^<t_") then
    replay.armed = true
  end
  if replay.armed and fast then
    replay.dropped = true
    return true
  end
  if replay.dropped then
    replay.armed, replay.dropped = false, false
  end
  return false
end

vim.on_key(function(key, typed)
  -- keys a mapping sends (typed == "", e.g. the `zv` after a debug step) are not
  -- what the viewer pressed
  if typed == nil or typed == "" then
    return
  end
  local s = vim.fn.keytrans(typed)
  if s == "" or s:match("Mouse") or s:match("ScrollWheel") then
    return
  end
  if is_fast_replay(key) or is_replay(key, s) then
    return
  end
  -- the mode before this key is handled decides which mapping table it belongs to
  local mode = vim.api.nvim_get_mode().mode
  vim.schedule(function()
    add_keys(s, mode)
    show()
    bump()
  end)
end)
