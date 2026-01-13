-- UI enhancements: which-key and trouble
return {
  -- Which-key: shows keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        win = {
          -- Floating window at bottom-right
          border = "rounded",
          padding = { 1, 2 },  -- { top/bottom, left/right }
          wo = {
            winblend = 0,  -- Fully opaque
          },
          -- Position at bottom-right
          width = { min = 20, max = 50 },
          height = { min = 4, max = 25 },
          row = -1,  -- Bottom of screen
          col = -1,  -- Right of screen
        },
        layout = {
          -- Column layout for better vertical display
          spacing = 3,
          align = "left",
        },
      })
    end,
  },

  -- Trouble: better diagnostics and quickfix list
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ..." },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
    config = function()
      require("trouble").setup({})
    end,
  },
}
