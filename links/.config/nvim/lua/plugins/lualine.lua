return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      theme = "tokyonight",
      component_separators = { left = "\u{E0B1}", right = "\u{E0B3}" },
      section_separators = { left = "\u{E0B0}", right = "\u{E0B2}" },
      globalstatus = true, -- single statusline for all windows
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        { "filename", path = 1, shorting_target = 40 }
      },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
