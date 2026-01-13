-- Command palette like VSCode/IntelliJ
return {
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      select = {
        backend = { "telescope" },
        telescope = {
          layout_config = {
            width = 0.6,
            height = 0.6,
          },
        },
      },
    },
  },
  {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    dependencies = {
      "folke/which-key.nvim",
      "nvim-telescope/telescope.nvim",
      "stevearc/dressing.nvim",
    },
    keys = {
      { "<leader>p", "<cmd>Legendary<cr>", desc = "Command palette" },
    },
    config = function()
      require("legendary").setup({
        select_prompt = "Command Palette",
        -- Include vim commands (ex commands)
        include_builtin = true,
        include_legendary_cmds = true,
        extensions = {
          which_key = {
            auto_register = true,
          },
        },
        -- Custom keymaps with descriptive keywords for discoverability
        keymaps = {
          -- Git operations (aliases for gitsigns)
          { "<leader>hr", description = "Git: Reset/Revert hunk (undo changes)" },
          { "<leader>hR", description = "Git: Reset/Revert entire buffer" },
          { "<leader>hs", description = "Git: Stage hunk" },
          { "<leader>hS", description = "Git: Stage entire buffer" },
          { "<leader>hu", description = "Git: Undo stage hunk" },
          { "<leader>hp", description = "Git: Preview hunk diff" },
          { "<leader>hb", description = "Git: Blame line" },
          { "<leader>hd", description = "Git: Diff this file" },
          { "]c", description = "Git: Next hunk" },
          { "[c", description = "Git: Previous hunk" },

          -- LSP operations
          { "gd", description = "LSP: Go to definition" },
          { "gr", description = "LSP: Find references" },
          { "K", description = "LSP: Hover documentation" },
          { "gK", description = "LSP: Signature help" },
          { "<leader>rn", description = "LSP: Rename symbol" },
          { "<leader>ca", description = "LSP: Code actions" },
          { "<leader>f", description = "LSP: Format code" },
          { "<leader>ci", description = "LSP: Incoming calls (call hierarchy)" },
          { "<leader>co", description = "LSP: Outgoing calls (call hierarchy)" },
          { "]d", description = "LSP: Next diagnostic" },
          { "[d", description = "LSP: Previous diagnostic" },
          { "gl", description = "LSP: Show diagnostic message" },

          -- Testing
          { "<leader>tt", description = "Test: Run nearest test" },
          { "<leader>td", description = "Test: Debug nearest test" },
          { "<leader>tf", description = "Test: Run all tests in file" },
          { "<leader>ts", description = "Test: Toggle test summary" },
          { "<leader>to", description = "Test: Show output" },
          { "<leader>tl", description = "Test: Run last test" },

          -- Debugging
          { "<leader>db", description = "Debug: Toggle breakpoint" },
          { "<leader>dB", description = "Debug: Conditional breakpoint" },
          { "<F5>", description = "Debug: Start/Continue" },
          { "<F10>", description = "Debug: Step over" },
          { "<F11>", description = "Debug: Step into" },
          { "<F12>", description = "Debug: Step out" },
          { "<leader>du", description = "Debug: Toggle UI" },
          { "<leader>dt", description = "Debug: Terminate" },
        },
      })
    end,
  },
}
