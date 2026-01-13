return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- nvim-notify removed - using snacks.notifier instead
  },
  keys = {
    { "<leader>snl", "<cmd>Noice last<cr>", desc = "Noice Last Message" },
    { "<leader>sna", "<cmd>Noice all<cr>", desc = "Noice All" },
  },
  opts = {
    cmdline = {
      view = "cmdline_popup", -- floating cmdline at top
    },
    -- Route notifications to snacks.notifier instead of nvim-notify
    routes = {
      {
        filter = { event = "notify" },
        view = "notify",
      },
    },
    -- Use snacks.notifier as the notify backend
    notify = {
      enabled = true,
      view = "notify",
    },
    presets = {
      bottom_search = false, -- use floating window for search too
      command_palette = true, -- cmdline and popupmenu together
      long_message_to_split = true, -- long messages go to split
      lsp_doc_border = true, -- add border to hover docs (matches your config)
    },
  },
}
