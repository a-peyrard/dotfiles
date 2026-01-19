-- Colorscheme configuration
return {
  -- Primary theme (loaded by default)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",
        on_colors = function(colors)
          colors.border = colors.orange
        end,
      })
      vim.cmd([[colorscheme tokyonight-storm]])
    end,
  },

  -- JetBrains-inspired theme (available via <leader>ft)
  {
    "nickkadutskyi/jb.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      snacks = {
        explorer = { enabled = true },
      },
    },
  },

  -- Rust-inspired theme (available via <leader>ft)
  {
    "nasccped/rustheme.nvim",
    lazy = false,
    priority = 1000,
  },
}
