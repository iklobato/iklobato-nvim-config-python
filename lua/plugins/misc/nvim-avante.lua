return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key or api_key == "" then
      vim.notify(
        "Avante AI: ANTHROPIC_API_KEY environment variable is not set. " ..
        "Please set it in your ~/.zshrc: export ANTHROPIC_API_KEY='your_key_here'",
        vim.log.levels.ERROR,
        { title = "Avante AI Configuration Error" }
      )
      return
    end

    require("avante").setup({
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          context_window = 200000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 64000,
          },
          api_key_name = "ANTHROPIC_API_KEY",
        },
      },
    })

    vim.cmd([[cab av Avante]])
  end,
}
