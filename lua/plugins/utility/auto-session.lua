return {
    'rmagatti/auto-session',
    config = function()
        require('auto-session').setup({
            log_level = "error",
            enabled = true,
            auto_save = true,
            auto_restore = true,
            auto_create = true,
            
            root_dir = vim.fn.stdpath("data") .. "/sessions/",
            auto_restore_last_session = true,  -- Always restore last session globally
            use_git_branch = true,
            
            cwd_change_handling = {
                restore_upcoming_session = true,
                pre_cwd_changed_hook = nil,
                post_cwd_changed_hook = function()
                    pcall(function()
                        require('nvim-tree.api').tree.reload()
                    end)
                end,
            },
            
            allowed_dirs = nil,
            suppressed_dirs = nil,
            
            bypass_save_filetypes = { "NvimTree" },
            
            pre_save_cmds = {
                function()
                    pcall(function()
                        require('nvim-tree.api').tree.close()
                    end)
                end,
            },
            
            post_restore_cmds = {
                function()
                    pcall(function()
                        require('nvim-tree.api').tree.open()
                    end)
                end,
            },

            -- Add session save hooks to handle multiple windows
            session_lens = {
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
            },
        })

        -- Add keymaps with proper error checking
        local status_ok, session_lens = pcall(require, "auto-session.session-lens")
        if status_ok then
            vim.keymap.set('n', '<leader>ss', function()
                session_lens.search_session()
            end, {desc = 'Search sessions'})
        end

        local auto_session = require('auto-session')
        vim.keymap.set('n', '<leader>sd', function()
            auto_session.DeleteSession()
        end, {desc = 'Delete session'})

        -- Ensure session saves on all exit commands (backup for :wqa, :qa, etc.)
        -- This provides redundancy in case auto_save somehow misses the exit
        -- Note: auto_save = true should already handle this, but this is a safety net
        local autocmd = vim.api.nvim_create_autocmd
        autocmd("VimLeavePre", {
            pattern = "*",
            callback = function()
                -- Force save session on exit as backup
                -- auto-session's auto_save should handle this, but this ensures it happens
                pcall(function()
                    auto_session.SaveSession()
                end)
            end,
        })

        -- Ensure all windows are visible after session restoration
        -- This fixes the issue where only one window is shown after restore
        local function ensure_windows_visible()
            -- Open NvimTree if it's not already open
            pcall(function()
                local nvim_tree = require('nvim-tree.api')
                -- Check if NvimTree is open by looking for its buffer
                local tree_open = false
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    local buf_name = vim.api.nvim_buf_get_name(buf)
                    if buf_name:match("NvimTree") then
                        tree_open = true
                        break
                    end
                end
                if not tree_open then
                    nvim_tree.tree.open()
                end
            end)
            
            -- Force redraw to ensure all windows are displayed
            vim.cmd("redraw!")
            -- Small delay to ensure windows are fully restored
            vim.defer_fn(function()
                vim.cmd("redraw!")
                local win_count = #vim.api.nvim_list_wins()
                if win_count > 1 then
                    -- Multiple windows exist, ensure they're all visible
                    vim.cmd("wincmd =")  -- Equalize window sizes
                end
            end, 100)
        end

        -- Try multiple event patterns to catch session restoration
        autocmd("User", {
            pattern = { "AutoSessionRestored", "auto-session-restored" },
            callback = ensure_windows_visible,
        })

        -- Always open NvimTree and ensure windows are visible after Neovim starts
        -- This runs after session restoration completes (if any) and ensures directory tree is always visible
        autocmd("VimEnter", {
            pattern = "*",
            callback = function()
                -- Wait a bit for session to restore (if any), then ensure windows are visible
                -- This also opens NvimTree automatically
                vim.defer_fn(ensure_windows_visible, 200)
            end,
        })
    end
}
