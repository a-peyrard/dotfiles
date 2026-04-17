-- Inline markdown rendering
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("render-markdown").setup({})

    vim.keymap.set("n", "<leader>um", function()
      require("render-markdown").toggle()
    end, { desc = "Toggle markdown preview" })
  end,
}
