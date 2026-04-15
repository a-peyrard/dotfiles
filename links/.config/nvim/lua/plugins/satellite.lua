-- Scrollbar with diagnostic, search, and VCS markers (JetBrains-style overview)
-- Shows colored ticks on the right edge for at-a-glance file overview
return {
  "lewis6991/satellite.nvim",
  event = "VeryLazy",
  config = function()
    require("satellite").setup({
      current_only = false,
      winblend = 20,
      zindex = 40,
      excluded_filetypes = {
        "snacks_dashboard",
        "lazy",
        "mason",
        "trouble",
        "help",
        "snacks_picker_input",
        "snacks_picker_list",
        "DiffviewFiles",
      },
      handlers = {
        cursor = { enable = true },
        search = { enable = true },
        diagnostic = {
          enable = true,
          min_severity = vim.diagnostic.severity.HINT,
        },
        gitsigns = { enable = true },
        marks = { enable = true, show_builtins = false },
        quickfix = { enable = true },
        -- Custom handlers loaded below via pcall (available when private plugins are deployed)
        signify = { enable = true },
        diff = { enable = true },
        claude = { enable = true },
      },
    })

    -- Load custom handlers if available (private bundle additions)
    pcall(require, "satellite.handlers.signify")
    pcall(require, "satellite.handlers.claude")
    pcall(require, "satellite.handlers.diff")
  end,
}
