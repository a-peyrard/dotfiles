-- Formatting with conform.nvim
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
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
      },

      -- Manual formatting only (use <leader>f)
      -- No format on save
      format_on_save = false,
    })
  end,
}
