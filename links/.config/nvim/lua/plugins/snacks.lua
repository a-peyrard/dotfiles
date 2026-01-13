-- snacks.nvim - unified plugin collection by folke
-- Replaces: telescope, neo-tree, indent-blankline, legendary, dressing, wilder
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Picker: replaces Telescope
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true },
      },
      win = {
        input = {
          keys = {
            ["<C-j>"] = { "list_down", mode = { "i", "n" } },
            ["<C-k>"] = { "list_up", mode = { "i", "n" } },
          },
        },
      },
    },

    -- Explorer: replaces neo-tree
    explorer = {
      enabled = true,
    },

    -- Indent guides: replaces indent-blankline
    indent = {
      enabled = true,
      char = "│",
      scope = {
        enabled = true,
      },
      animate = {
        duration = { step = 10, total = 100 }, -- faster animation
      },
    },

    -- Input: replaces dressing.nvim for vim.ui.input/select
    input = {
      enabled = true,
    },

    -- Notifier: replaces nvim-notify
    notifier = {
      enabled = true,
      timeout = 3000,
    },

    -- Additional useful features
    quickfile = { enabled = true }, -- Fast file open
    statuscolumn = { enabled = false }, -- Keep default status column
    words = { enabled = true }, -- Word navigation
    scope = { enabled = true }, -- Scope detection
  },
  keys = {
    -- File operations (same as before)
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Tags" },

    -- New: keymaps and commands (replaces legendary) - no preview
    { "<leader>fk", function() Snacks.picker.keymaps({ layout = { preview = false } }) end, desc = "Keymaps" },
    { "<leader>fc", function() Snacks.picker.commands({ layout = { preview = false } }) end, desc = "Commands" },

    -- File explorer (replaces neo-tree)
    { "<leader>e", function() Snacks.explorer() end, desc = "Toggle Explorer" },

    -- Additional pickers
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>f/", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols (buffer)" },
    { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Symbols (project)" },
    { "<leader>fi", function() Snacks.picker.icons() end, desc = "Icons/Emoji" },
    { "<leader>ft", function() Snacks.picker.colorschemes() end, desc = "Themes/Colorschemes" },

    -- Git pickers
    { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Commits" },
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },

    -- Notifications
    { "<leader>snd", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<leader>snh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
  },
  init = function()
    -- Setup global Snacks variable for use in keymaps
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Create global toggle functions
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.inlay_hints():map("<leader>uh")
      end,
    })
  end,
}
