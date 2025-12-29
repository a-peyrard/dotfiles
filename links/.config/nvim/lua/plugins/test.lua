-- Test runner with visual explorer (like VSCode/IntelliJ)
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      -- Rust test adapter
      "rouge8/neotest-rust",
    },
    keys = {
      { "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
      { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run all tests in file" },
      { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Toggle test summary" },
      { "<leader>to", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = "Show test output" },
      { "<leader>tO", "<cmd>lua require('neotest').output_panel.toggle()<cr>", desc = "Toggle output panel" },
      { "<leader>tl", "<cmd>lua require('neotest').run.run_last()<cr>", desc = "Run last test" },
      { "<leader>tS", "<cmd>lua require('neotest').run.stop()<cr>", desc = "Stop test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust") {
            args = { "--no-capture" },  -- Show println! output
          },
        },
        -- Show test status in sign column
        status = {
          enabled = true,
          virtual_text = false,  -- Don't clutter with virtual text
          signs = true,          -- Show icons in sign column
        },
        -- Icons for test status
        icons = {
          passed = "✓",
          running = "⟳",
          failed = "✗",
          skipped = "⊘",
          unknown = "?",
        },
        -- Floating window configuration
        floating = {
          border = "rounded",
          max_height = 0.8,
          max_width = 0.8,
        },
        -- Output configuration
        output = {
          enabled = true,
          open_on_run = false,  -- Don't auto-open output (use <leader>to)
        },
        -- Summary window (test explorer sidebar)
        summary = {
          enabled = true,
          follow = true,         -- Follow current file
          expand_errors = true,  -- Auto-expand failed tests
        },
      })
    end,
  },
}
