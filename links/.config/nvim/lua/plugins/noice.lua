return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
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
