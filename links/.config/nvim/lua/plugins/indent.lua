-- Indent guides with scope highlighting (like IntelliJ)
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("ibl").setup({
      -- Show indent guides
      indent = {
        char = "│",  -- Character for indent lines
        tab_char = "│",
      },

      -- Highlight current scope (the block where cursor is)
      scope = {
        enabled = true,
        show_start = true,  -- Show line at start of scope
        show_end = true,    -- Show line at end of scope
        highlight = { "Function", "Label" },  -- Colors for scope line
      },

      -- Exclude certain file types
      exclude = {
        filetypes = {
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "trouble",
          "Trouble",
        },
      },
    })
  end,
}
