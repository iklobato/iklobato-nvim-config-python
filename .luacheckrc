-- Luacheck configuration for Neovim config
-- Allow vim global (provided by Neovim)
globals = {
    "vim",
}

-- Standard Lua globals
std = "lua54"

-- Ignore unused arguments in function definitions (common in Neovim configs)
unused_args = false

-- Ignore unused secondaries (common in Neovim configs)
unused_secondaries = false

-- Allow redefining globals
redefined = true

-- Allow unused globals
unused_globals = false

-- Check for undefined globals
undefined = true

-- Maximum line length
max_line_length = 210
