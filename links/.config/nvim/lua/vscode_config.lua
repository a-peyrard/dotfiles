-- VSCode-specific minimal configuration
-- This file is only loaded when running Neovim inside VSCode
-- VSCode provides: LSP, completion, file explorer, debugger, git UI, themes
-- We only load plugins that enhance the editing experience

-- Bootstrap lazy.nvim (assume it's already installed from full Neovim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  error("lazy.nvim not found. Please run Neovim (not VSCode) first to install plugins.")
end
vim.opt.rtp:prepend(lazypath)

-- Load ONLY these minimal plugins in VSCode (NOT the lua/plugins/ directory)
require("lazy").setup({
  -- Fast navigation with leap.nvim
  -- Usage: s{char}{char} to jump forward, S{char}{char} to jump backward
  {
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")
    end,
  },

  -- Optional: Add more VSCode-compatible plugins here after testing
  -- Examples of plugins that might work well:
  -- {
  --   "windwp/nvim-autopairs",
  --   event = "InsertEnter",
  --   config = function()
  --     require("nvim-autopairs").setup()
  --   end,
  -- },
  -- {
  --   "sustech-data/wildfire.nvim",
  --   event = "VeryLazy",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   config = function()
  --     require("wildfire").setup({
  --       keymaps = {
  --         init_selection = "gn",
  --         node_incremental = "<CR>",
  --         node_decremental = "<BS>",
  --       },
  --     })
  --   end,
  -- },
})
