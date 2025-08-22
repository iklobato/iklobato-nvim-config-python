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
              -- Replace with your Anthropic API key or use an environment variable
              api_key = os.getenv("ANTHROPIC_API_KEY"),
            },
            schema = {
              model = {
                -- Set Claude 3.5 Sonnet as the default model
                default = "claude-3-opus-20240229",
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

