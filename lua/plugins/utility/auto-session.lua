return {
    'rmagatti/auto-session',
    lazy = false,  -- Must load on startup for auto-restore to work
    config = function()
        require('auto-session').setup({})
    end
}
