-- Formatting with conform.nvim
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      desc = "Format code",
    },
  },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        -- Python: ruff for formatting
        python = { "ruff_format" },

        -- Rust: rustfmt for formatting
        rust = { "rustfmt" },

        -- Lua: stylua for formatting (keeps your Neovim config clean)
        lua = { "stylua" },

        -- Go: goimports for imports + gofmt for formatting
        go = { "goimports", "gofmt" },

        -- JSON: jq for formatting
        json = { "jq" },
      },

      -- Manual formatting only (use <leader>f)
      -- No format on save
      format_on_save = false,
    })
  end,
}
