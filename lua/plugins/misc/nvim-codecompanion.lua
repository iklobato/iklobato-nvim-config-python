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
  end,
}

