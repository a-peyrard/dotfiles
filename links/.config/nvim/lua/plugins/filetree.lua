-- File explorer with neo-tree
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      window = {
        width = 30,
        mappings = {
          -- Keyboard-friendly navigation
          ["<space>"] = "toggle_node",
          ["<cr>"] = "open",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["C"] = "close_node",
          ["a"] = "add",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["R"] = "refresh",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
    })
  end,
}
