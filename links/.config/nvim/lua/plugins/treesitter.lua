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
      require("nvim-treesitter").setup({
        ensure_installed = {
          "python", "go", "rust", "lua", "bash",
          "c", "cpp", "thrift",
          "json", "yaml", "toml",
          "markdown", "markdown_inline",
          "vim", "vimdoc",
        },
      })

      -- Enable highlighting automatically for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          pcall(vim.treesitter.start) -- Use pcall in case parser not installed
        end,
      })
    end,
  },

  -- Sticky context: pins enclosing function/class/block at top of window
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        max_lines = 10,
        min_window_height = 20,
        separator = "─",
      })

      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#3b4261" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })

      vim.keymap.set("n", "<leader>uc", function()
        require("treesitter-context").toggle()
      end, { desc = "Toggle treesitter context" })

      vim.keymap.set("n", "[x", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { desc = "Jump to context" })
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
