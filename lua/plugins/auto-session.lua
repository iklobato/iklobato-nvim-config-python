return {
    'rmagatti/auto-session',
    lazy = false,  -- Must load on startup for auto-restore to work
    priority = 900, -- High priority: load early for session restore
    config = function()
        require('auto-session').setup({
            suppressed_dirs = { '~/', '~/Downloads', '/' },
            bypass_save_filetypes = { 'alpha', 'dashboard', 'neo-tree', 'NvimTree' },
        })
    end
}
