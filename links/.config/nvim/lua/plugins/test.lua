-- Test runner with visual explorer (like VSCode/IntelliJ)
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",  -- REQUIRED for neotest-golang v2+
      },
      {
        "fredrikaverpil/neotest-golang",
        version = "*",  -- Track releases
        build = function()
          -- Optional but recommended: install gotestsum for better stability
          vim.system({"go", "install", "gotest.tools/gotestsum@latest"}):wait()
        end,
      },
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-python",
    },
    keys = {
      { "<leader>tt", function() require('neotest').run.run() end, desc = "Run nearest test" },
      { "<leader>td", function() require('neotest').run.run({ strategy = 'dap' }) end, desc = "Debug nearest test" },
      { "<leader>tf", function() require('neotest').run.run(vim.fn.expand('%')) end, desc = "Run all tests in file" },
      { "<leader>ts", function() require('neotest').summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require('neotest').output.open({ enter = true }) end, desc = "Show test output" },
      { "<leader>tO", function() require('neotest').output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tl", function() require('neotest').run.run_last() end, desc = "Run last test" },
      { "<leader>tS", function() require('neotest').run.stop() end, desc = "Stop test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            runner = "gotestsum",  -- Use gotestsum for better stability
          }),
          require("neotest-rust")({
            args = { "--no-capture" },
          }),
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
        icons = {
          passed = "✓",
          running = "⟳",
          failed = "✗",
          skipped = "⊘",
          unknown = "?",
        },
        floating = {
          border = "rounded",
          max_height = 0.8,
          max_width = 0.8,
        },
        output = {
          enabled = true,
          open_on_run = false,
        },
        summary = {
          enabled = true,
          follow = true,
          expand_errors = true,
        },
      })

      -- Define highlight groups for neotest signs so they're visible
      vim.api.nvim_set_hl(0, "NeotestPassed", { fg = "#50fa7b" })
      vim.api.nvim_set_hl(0, "NeotestFailed", { fg = "#ff5555" })
      vim.api.nvim_set_hl(0, "NeotestRunning", { fg = "#f1fa8c" })
      vim.api.nvim_set_hl(0, "NeotestSkipped", { fg = "#6272a4" })
    end,
  },
}
