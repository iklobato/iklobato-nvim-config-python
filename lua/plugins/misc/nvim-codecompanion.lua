return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionActions",
    "CodeCompanionCmd",
  },
  config = function()
    -- Validate API key before setup
    local api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key or api_key == "" then
      vim.notify(
        "CodeCompanion: ANTHROPIC_API_KEY environment variable is not set. " ..
        "Please set it in your ~/.zshrc: export ANTHROPIC_API_KEY='your_key_here'",
        vim.log.levels.ERROR,
        { title = "CodeCompanion Configuration Error" }
      )
      return
    end

    require("codecompanion").setup({
      -- Set Anthropic as the default adapter for all strategies
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
      
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              -- Read Anthropic API key from environment variable
              api_key = api_key,
            },
            schema = {
              model = {
                -- Set Claude Sonnet 4.5 as the default model
                default = "claude-sonnet-4-5-20250929",
              },
            },
          })
        end,
      },
      
      display = {
        action_palette = {
          provider = "telescope", -- or "mini_pick"
        },
      },
      
      opts = {
        log_level = "INFO",
      },
    })

    -- Optional: Command abbreviation
    vim.cmd([[cab cc CodeCompanion]])

    -- Configure chat buffer to allow slash commands and @ tags
    -- This ensures the buffer is in insert mode and allows typing special characters
    local autocmd = vim.api.nvim_create_autocmd
    
    -- Function to configure CodeCompanion chat buffer
    local function configure_chat_buffer()
      -- Ensure buffer is modifiable
      vim.bo.modifiable = true
      -- Allow normal typing of special characters (clear any special buftype)
      vim.bo.buftype = ""
      -- Ensure buffer is not readonly
      vim.bo.readonly = false
    end
    
    -- Detect CodeCompanion chat buffers by filetype
    autocmd("FileType", {
      pattern = { "codecompanion", "CodeCompanion" },
      callback = function()
        configure_chat_buffer()
        -- Automatically enter insert mode when buffer is opened
        vim.cmd("startinsert")
      end,
    })

    -- Detect CodeCompanion chat buffers by buffer name pattern
    autocmd({ "BufEnter", "BufWinEnter" }, {
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        local filetype = vim.bo.filetype
        -- Check if this is a CodeCompanion buffer
        if (bufname and (bufname:match("[Cc]ode[Cc]ompanion") or bufname:match("codecompanion"))) or
           (filetype and (filetype:match("[Cc]ode[Cc]ompanion") or filetype:match("codecompanion"))) then
          configure_chat_buffer()
          -- Only enter insert mode if we're at or near the end of the buffer (input area)
          local line_count = vim.api.nvim_buf_line_count(0)
          local current_line = vim.api.nvim_win_get_cursor(0)[1]
          if line_count > 0 and current_line >= math.max(1, line_count - 2) then
            vim.cmd("startinsert")
          end
        end
      end,
    })

    -- Handle User events from CodeCompanion (if available)
    autocmd("User", {
      pattern = { "CodeCompanionChatOpened", "CodeCompanionChatNew", "CodeCompanion*" },
      callback = function()
        configure_chat_buffer()
        vim.cmd("startinsert")
      end,
    })
  end,
}

