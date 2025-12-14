return {
    'rmagatti/auto-session',
    lazy = false,  -- Must load on startup for auto-restore to work
    priority = 900, -- High priority: load early for session restore
    config = function()
        require('auto-session').setup({})
    end
}
