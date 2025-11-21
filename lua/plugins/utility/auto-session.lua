return {
    'rmagatti/auto-session',
    event = 'VeryLazy',  -- Defer loading to reduce startup time
    config = function()
        -- Function to generate a unique session name based on directory path
        -- This ensures each directory has its own session
        local function get_session_name()
            local cwd = vim.fn.getcwd()
            -- Normalize the path (remove trailing slashes, resolve symlinks)
            cwd = vim.fn.fnamemodify(cwd, ':p')
            cwd = vim.fn.substitute(cwd, '/$', '', '')
            
            -- Create a hash of the path for uniqueness
            -- Use a simple hash function to create a manageable name
            local hash = 0
            for i = 1, #cwd do
                local char = string.byte(cwd, i)
                -- Use multiplication instead of bit shift: hash << 5 is equivalent to hash * 32
                hash = ((hash * 32) - hash) + char
                -- Keep hash within 32-bit range for consistency
                hash = hash % (2^32)
            end
            
            -- Use absolute hash value and directory name for readability
            local dir_name = vim.fn.fnamemodify(cwd, ':t')
            if dir_name == '' then
                dir_name = vim.fn.fnamemodify(cwd, ':h:t')
            end
            
            -- Sanitize directory name for use in filename
            dir_name = vim.fn.substitute(dir_name, '[^a-zA-Z0-9_-]', '_', 'g')
            
            -- Combine directory name with hash for uniqueness
            local session_name = string.format("%s_%x", dir_name, math.abs(hash))
            return session_name
        end
        
        require('auto-session').setup({
            log_level = "error",
            enabled = true,
            auto_save = true,
            auto_restore = true,
            auto_create = true,
            
            root_dir = vim.fn.stdpath("data") .. "/sessions/",
            auto_restore_last_session = true,  -- Always restore last session globally
            use_git_branch = false,  -- Disable git branch-based sessions
            session_name = get_session_name,  -- Use directory-based session names
            
            cwd_change_handling = {
                restore_upcoming_session = true,
                pre_cwd_changed_hook = function()
                    -- Save current session before changing directory
                    pcall(function()
                        local auto_session = require('auto-session')
                        auto_session.SaveSession()
                    end)
                end,
                post_cwd_changed_hook = function()
                    -- Reload nvim-tree after directory change
                    pcall(function()
                        require('nvim-tree.api').tree.reload()
                    end)
                    -- Restore the new directory's session
                    vim.defer_fn(function()
                        pcall(function()
                            local auto_session = require('auto-session')
                            auto_session.RestoreSession()
                        end)
                    end, 100)
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
        -- Note: We do NOT equalize window sizes here to preserve saved window layouts
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
            -- This ensures windows restored from session are visible
            vim.defer_fn(function()
                vim.cmd("redraw!")
                -- Verify all windows are properly displayed
                -- Session restoration should preserve window sizes and positions
                -- so we don't modify them here
            end, 100)
        end

        -- Try multiple event patterns to catch session restoration
        autocmd("User", {
            pattern = { "AutoSessionRestored", "auto-session-restored" },
            callback = ensure_windows_visible,
        })

        -- Always open NvimTree and ensure windows are visible after Neovim starts
        -- This runs after session restoration completes (if any) and ensures directory tree is always visible
        -- Defer to reduce startup time
        autocmd("VimEnter", {
            pattern = "*",
            callback = function()
                -- Defer window visibility check to reduce startup blocking
                -- Session restoration happens asynchronously, so we wait longer
                vim.defer_fn(ensure_windows_visible, 300)
            end,
        })
    end
}
