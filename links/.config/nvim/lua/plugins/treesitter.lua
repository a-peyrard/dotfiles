-- Treesitter configuration for syntax highlighting
return {
  -- Core treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",  -- REQUIRED for neotest-golang v2+
    build = ":TSUpdate",
    lazy = false,
    priority = 100,
    config = function()
      -- Enable highlighting automatically for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          pcall(vim.treesitter.start) -- Use pcall in case parser not installed
        end,
      })
    end,
  },

  -- Incremental selection plugin (like IntelliJ's expand selection)
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("wildfire").setup({
        keymaps = {
          init_selection = "gn",
          node_incremental = "<CR>",
          node_decremental = "<BS>",
        },
      })
    end,
  },
}
