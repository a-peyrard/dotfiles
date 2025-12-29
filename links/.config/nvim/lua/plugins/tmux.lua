-- Tmux integration for seamless navigation
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate Left (tmux-aware)" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate Down (tmux-aware)" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate Up (tmux-aware)" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate Right (tmux-aware)" },
  },
}
