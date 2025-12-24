return {
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "http", "rest" },
    config = function()
      -- Register tree-sitter parser to prevent attachment errors
      pcall(function()
        vim.treesitter.language.add("http", {
          path = vim.fn.stdpath("data") .. "/lazy-rocks/rest.nvim/lib/lua/5.1/parser/http.so"
        })
      end)

      require("rest-nvim").setup({
        -- Show response in horizontal split within the current window
        result_split_horizontal = true,
        result_split_in_place = true,
        -- Alternative configuration for in-window splitting
        result = {
          show_curl_command = true,
          show_headers = true,
          show_url = true,
          -- Configure result window behavior
          behavior = {
            decode_url = false,
            statistics = {
              enable = true,
            },
          },
          -- Custom formatter for JSON responses
          formatters = {
            json = function(body)
              -- Check if jq is available and format JSON
              if vim.fn.executable('jq') == 1 then
                local formatted = vim.fn.system('echo ' .. vim.fn.shellescape(body) .. ' | jq . 2>/dev/null')
                if vim.v.shell_error == 0 and formatted ~= "" then
                  return formatted
                end
              end
              -- Fallback: return original body if jq fails
              return body
            end,
          },
        },
      })
    end,
  }
}