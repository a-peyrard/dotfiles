-- Fast navigation with flash.nvim
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Labels appear next to matches
    labels = "asdfghjklqwertyuiopzxcvbnm",
    search = {
      -- Search/jump in all windows
      multi_window = true,
    },
    jump = {
      -- Automatically jump when there is only one match
      autojump = true,
    },
    modes = {
      -- Enhanced f/t/F/T motions
      char = {
        enabled = true,
        jump_labels = true,
      },
      -- Treesitter integration
      treesitter = {
        labels = "asdfghjklqwertyuiopzxcvbnm",
        jump = { pos = "range" },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
