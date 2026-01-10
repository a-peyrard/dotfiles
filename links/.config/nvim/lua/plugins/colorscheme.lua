-- Colorscheme configuration
return {
  "folke/tokyonight.nvim",
  lazy = false, -- Load immediately during startup
  priority = 1000, -- Load before other plugins
  config = function()
    require("tokyonight").setup({
      style = "storm", -- darker blue variant
      on_colors = function(colors)
        colors.border = colors.orange -- orange borders like server config
      end,
    })
    vim.cmd([[colorscheme tokyonight-storm]])
  end,
}
