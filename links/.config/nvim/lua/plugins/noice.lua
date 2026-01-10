return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  keys = {
    { "<leader>snl", "<cmd>Noice last<cr>", desc = "Noice Last Message" },
    { "<leader>snh", "<cmd>Noice history<cr>", desc = "Noice History" },
    { "<leader>snd", "<cmd>Noice dismiss<cr>", desc = "Dismiss All" },
    { "<leader>sna", "<cmd>Noice all<cr>", desc = "Noice All" },
  },
  opts = {
    cmdline = {
      view = "cmdline_popup", -- floating cmdline at top
    },
    presets = {
      bottom_search = false, -- use floating window for search too
      command_palette = true, -- cmdline and popupmenu together
      long_message_to_split = true, -- long messages go to split
      lsp_doc_border = true, -- add border to hover docs (matches your config)
    },
  },
}
