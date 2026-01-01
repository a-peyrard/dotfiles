-- Colorscheme configuration
return {
  "folke/tokyonight.nvim",
  lazy = false, -- Load immediately during startup
  priority = 1000, -- Load before other plugins
  config = function()
    require("tokyonight").setup({
      transparent = true, -- Enable transparent background
      styles = {
        sidebars = "transparent", -- Sidebar backgrounds (neo-tree, etc.)
        floats = "transparent", -- Floating window backgrounds
      },
    })
    vim.cmd([[colorscheme tokyonight]])

    -- Additional transparency settings for complete coverage
    local highlights = {
      "Normal",
      "NormalFloat",
      "NormalNC", -- Non-current windows
      "SignColumn",
      "LineNr",
      "Folded",
      "EndOfBuffer",
      "NeoTreeNormal", -- Neo-tree file explorer
      "NeoTreeNormalNC",
      "TelescopeNormal", -- Telescope fuzzy finder
      "TelescopeBorder",
      "TroubleNormal", -- Trouble diagnostics panel
      "WhichKeyFloat", -- Which-key popup
      -- DAP (Debug) UI panels
      "DapUIScope",
      "DapUIType",
      "DapUIDecoration",
      "DapUIThread",
      "DapUIStoppedThread",
      "DapUIFrameName",
      "DapUIBreakpointsPath",
      "DapUIBreakpointsInfo",
      "DapUIBreakpointsCurrentLine",
      "DapUIWatchesEmpty",
      "DapUIWatchesValue",
      "DapUIWatchesError",
      -- Neotest panels
      "NeotestNormal",
      "NeotestBorder",
    }

    for _, group in ipairs(highlights) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
}
