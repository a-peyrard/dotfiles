-- Conflict resolution UI (works with Git, Mercurial, and Sapling)
-- Run :DiffviewOpen during merge/rebase to see conflicted files in 3-way diff
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview (conflicts)" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
  },
  config = function()
    local actions = require("diffview.actions")
    require("diffview").setup({
      enhanced_diff_hl = true,
      use_icons = true,
      hg_cmd = { "sl" },  -- Use Sapling instead of hg
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
      keymaps = {
        view = {
          -- Conflict resolution (same style as git-conflict.nvim)
          { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
          { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
          { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
          { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL" } },
          { "n", "dx", actions.conflict_choose("none"), { desc = "Delete conflict" } },
          -- Navigation between conflicts
          { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
        },
        file_panel = {
          { "n", "j", actions.next_entry, { desc = "Next entry" } },
          { "n", "k", actions.prev_entry, { desc = "Previous entry" } },
          { "n", "<cr>", actions.select_entry, { desc = "Open entry" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
        },
      },
    })
  end,
}
