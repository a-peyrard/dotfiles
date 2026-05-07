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
      lualine_b = {
        "branch", "diff", "diagnostics",
        {
          function() return "REVIEW" end,
          cond = function() return _G.signify_review and _G.signify_review.review_mode end,
          color = { fg = "#e5c07b", gui = "bold" },
        },
        {
          function()
            local n = vim.g.diff_review_remaining or 0
            if n == 0 then return "󰚩 DIFF ✓" end
            return string.format("󰚩 DIFF %d", n)
          end,
          cond = function() return vim.g.diff_review_active end,
          color = function()
            local n = vim.g.diff_review_remaining or 0
            if n == 0 then return { fg = "#9ece6a", gui = "bold" } end
            return { fg = "#7aa2f7", gui = "bold" }
          end,
        },
      },
      lualine_c = {
        { "filename", path = 1, shorting_target = 40 }
      },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
