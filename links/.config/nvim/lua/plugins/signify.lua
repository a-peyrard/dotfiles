-- vim-signify for Mercurial/Sapling support (Git handled by gitsigns)
return {
  "mhinz/vim-signify",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    -- Only use signify for Mercurial and Sapling (let gitsigns handle Git)
    vim.g.signify_vcs_list = { "hg", "sapling" }

    -- Thin vertical bar signs (JetBrains-style, statuscol positions after line numbers)
    vim.g.signify_sign_add = "▎"
    vim.g.signify_sign_delete = "▎"
    vim.g.signify_sign_delete_first_line = "▎"
    vim.g.signify_sign_change = "▎"
    vim.g.signify_sign_change_delete = "▎"
    vim.g.signify_sign_show_count = 0

    -- Update signs asynchronously
    vim.g.signify_async = 1

    -- Keybindings for hunk navigation (same as gitsigns)
    -- Note: ]c and [c are set by both plugins, they'll work in respective repos
  end,
  config = function()
    -- Line number highlights for VCS changes (signify uses these with number_highlight=1)
    vim.api.nvim_set_hl(0, "SignifyLineAdd", { fg = "#98c379", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignifyLineDelete", { fg = "#e06c75", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignifyLineChange", { fg = "#e5c07b", bg = "NONE" })
    -- Keep sign highlights in case they're still used
    vim.api.nvim_set_hl(0, "SignifySignAdd", { fg = "#98c379", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignifySignDelete", { fg = "#e06c75", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignifySignChange", { fg = "#e5c07b", bg = "NONE" })

    -- Additional keymaps for signify-specific features
    vim.keymap.set("n", "<leader>hd", "<cmd>SignifyDiff<cr>", { desc = "Signify: Diff this" })
    vim.keymap.set("n", "<leader>hp", "<cmd>SignifyHunkDiff<cr>", { desc = "Signify: Preview hunk" })
    vim.keymap.set("n", "<leader>hu", "<cmd>SignifyHunkUndo<cr>", { desc = "Signify: Undo hunk" })

    -- Full file revert for Sapling/Mercurial
    vim.keymap.set("n", "<leader>hR", function()
      local file = vim.fn.expand("%")
      -- Try Sapling first, then Mercurial
      local cmd = vim.fn.executable("sl") == 1 and "sl revert " or "hg revert "
      vim.fn.system(cmd .. vim.fn.shellescape(file))
      vim.cmd("edit!")  -- Reload the buffer
      vim.notify("Reverted: " .. file, vim.log.levels.INFO)
    end, { desc = "Signify: Revert file" })
  end,
}
