-- vim-signify for Mercurial/Sapling support (Git handled by gitsigns)
return {
  "mhinz/vim-signify",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    -- Only use signify for Mercurial and Sapling (let gitsigns handle Git)
    vim.g.signify_vcs_list = { "hg", "sapling" }

    -- Thick centered vertical bar signs (JetBrains-style, statuscol positions after line numbers)
    vim.g.signify_sign_add = "┃"
    vim.g.signify_sign_delete = "┃"
    vim.g.signify_sign_delete_first_line = "┃"
    vim.g.signify_sign_change = "┃"
    vim.g.signify_sign_change_delete = "┃"
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

    -- Review mode: toggle diff base between . (uncommitted) and .^ (last commit)
    local review_state = {
      review_mode = false,
      normal_cmd = "hg --config alias.diff=diff diff --color=never --nodates -U0 -- %f",
      review_cmd = "hg --config alias.diff=diff diff --color=never --nodates -U0 --rev .^ -- %f",
      normal_diffmode_cmd = "hg cat %f",
      review_diffmode_cmd = "hg cat --rev .^ %f",
    }
    -- Expose for lualine statusline indicator
    _G.signify_review = review_state

    local function set_vcs_cmds(diff_cmd, diffmode_cmd)
      local cmds = vim.g.signify_vcs_cmds or {}
      cmds.hg = diff_cmd
      vim.g.signify_vcs_cmds = cmds

      local dm_cmds = vim.g.signify_vcs_cmds_diffmode or {}
      dm_cmds.hg = diffmode_cmd
      vim.g.signify_vcs_cmds_diffmode = dm_cmds
    end

    local function toggle_review_mode()
      review_state.review_mode = not review_state.review_mode

      if review_state.review_mode then
        set_vcs_cmds(review_state.review_cmd, review_state.review_diffmode_cmd)
        vim.notify("Signify: Review mode ON (diffing against .^)", vim.log.levels.INFO)
      else
        set_vcs_cmds(review_state.normal_cmd, review_state.normal_diffmode_cmd)
        vim.notify("Signify: Review mode OFF (diffing against .)", vim.log.levels.INFO)
      end

      vim.cmd("SignifyRefresh")
    end

    -- Toggle review mode
    vim.keymap.set("n", "<leader>hc", toggle_review_mode,
      { desc = "Signify: Toggle review mode (diff .^)" })

    -- Additional keymaps for signify-specific features
    vim.keymap.set("n", "<leader>hd", "<cmd>SignifyDiff<cr>", { desc = "Signify: Diff this" })
    vim.keymap.set("n", "<leader>hp", "<cmd>SignifyHunkDiff<cr>", { desc = "Signify: Preview hunk" })

    -- Undo hunk — guarded in review mode
    vim.keymap.set("n", "<leader>hu", function()
      if review_state.review_mode then
        vim.notify("Hunk undo disabled in review mode (would revert to .^ state)", vim.log.levels.WARN)
        return
      end
      vim.cmd("SignifyHunkUndo")
    end, { desc = "Signify: Undo hunk" })

    -- Full file revert — guarded in review mode
    vim.keymap.set("n", "<leader>hR", function()
      if review_state.review_mode then
        vim.notify("File revert disabled in review mode", vim.log.levels.WARN)
        return
      end
      local file = vim.fn.expand("%")
      local cmd = vim.fn.executable("sl") == 1 and "sl revert " or "hg revert "
      vim.fn.system(cmd .. vim.fn.shellescape(file))
      vim.cmd("edit!")
      vim.notify("Reverted: " .. file, vim.log.levels.INFO)
    end, { desc = "Signify: Revert file" })

    -- List all hunks in quickfix
    vim.keymap.set("n", "<leader>hL", function()
      vim.cmd("SignifyListUnstaged")
      vim.cmd("copen")
    end, { desc = "Signify: List all hunks" })

    -- Telescope hunk picker (works in both normal and review mode)
    vim.keymap.set("n", "<leader>hh", function()
      require("config.sapling-hunks").open()
    end, { desc = "Sapling: Browse hunks (telescope)" })
  end,
}
