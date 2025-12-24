return {
    "echasnovski/mini.surround",
    version = "*",
    priority = 800, -- High priority: core editing utility
    config = function()
        require("mini.surround").setup({})
    end,
}
