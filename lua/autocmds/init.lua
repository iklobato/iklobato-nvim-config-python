-- Load all autocommand categories
require("autocmds.filetypes")
require("autocmds.session")
require("autocmds.ui")

-- Load Python-specific configurations
require("config.python_hl").setup()