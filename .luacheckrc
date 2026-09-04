-- Luacheck configuration for Neovim config
-- Allow vim global (provided by Neovim)
globals = {
    "vim",
}

-- Neovim runs LuaJIT, not 5.4: "lua54" false-flags unpack() and jit.*
std = "luajit"

-- Ignore unused arguments in function definitions (common in Neovim configs)
unused_args = false

-- Ignore unused secondaries (common in Neovim configs)
unused_secondaries = false

-- Allow redefining globals
redefined = true

-- stylua owns line width (stylua.toml column_width). Two numbers that disagree
-- is worse than one.
max_line_length = false
