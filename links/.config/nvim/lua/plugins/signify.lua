-- vim-signify for Mercurial/Sapling support (Git handled by gitsigns)
return {
  "mhinz/vim-signify",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    -- Only use signify for Mercurial and Sapling (let gitsigns handle Git)
    vim.g.signify_vcs_list = { "hg", "sapling" }

    -- Sign characters (matching gitsigns style)
    vim.g.signify_sign_add = "+"
    vim.g.signify_sign_delete = "_"
    vim.g.signify_sign_delete_first_line = "‾"
    vim.g.signify_sign_change = "~"
    vim.g.signify_sign_change_delete = "~"

    -- Update signs asynchronously
    vim.g.signify_async = 1

    -- Keybindings for hunk navigation (same as gitsigns)
    -- Note: ]c and [c are set by both plugins, they'll work in respective repos
  end,
  config = function()
    -- Additional keymaps for signify-specific features
    vim.keymap.set("n", "<leader>hd", "<cmd>SignifyDiff<cr>", { desc = "Signify: Diff this" })
    vim.keymap.set("n", "<leader>hp", "<cmd>SignifyHunkDiff<cr>", { desc = "Signify: Preview hunk" })
    vim.keymap.set("n", "<leader>hu", "<cmd>SignifyHunkUndo<cr>", { desc = "Signify: Undo hunk" })
  end,
}
