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

    local review_state = {
      review_mode = false,
      current_rev = ".",
      normal_cmd = "hg --config alias.diff=diff diff --color=never --nodates -U0 -- %f",
      normal_diffmode_cmd = "hg cat %f",
    }
    _G.signify_review = review_state

    local function set_vcs_cmds(diff_cmd, diffmode_cmd)
      local cmds = vim.g.signify_vcs_cmds or {}
      cmds.hg = diff_cmd
      vim.g.signify_vcs_cmds = cmds

      local dm_cmds = vim.g.signify_vcs_cmds_diffmode or {}
      dm_cmds.hg = diffmode_cmd
      vim.g.signify_vcs_cmds_diffmode = dm_cmds
    end

    local function set_review_mode(enabled, rev)
      rev = rev or "."
      review_state.review_mode = enabled
      review_state.current_rev = rev

      if enabled then
        local parent = rev .. "^"
        set_vcs_cmds(
          string.format("hg --config alias.diff=diff diff --color=never --nodates -U0 --rev %s -- %%f", parent),
          string.format("hg cat --rev %s %%f", parent)
        )
        vim.notify(string.format("Review mode ON (diff against %s)", parent))
      else
        set_vcs_cmds(review_state.normal_cmd, review_state.normal_diffmode_cmd)
        vim.notify("Review mode OFF")
      end

      vim.cmd("SignifyRefresh")
    end

    review_state.set_review_mode = set_review_mode

    vim.keymap.set("n", "<leader>hc", function()
      set_review_mode(not review_state.review_mode)
    end, { desc = "Signify: Toggle review mode (diff .^)" })

    -- Additional keymaps for signify-specific features
    vim.keymap.set("n", "<leader>hd", "<cmd>SignifyDiff<cr>", { desc = "Signify: Diff this" })

    -- Hunk preview in a floating window (replaces SignifyHunkDiff)
    vim.keymap.set("n", "<leader>hp", function()
      -- Capture SignifyHunkDiff output
      local output = vim.fn.execute("SignifyHunkDiff")
      -- The diff is now in the preview window — find it and move to floating
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.wo[win].previewwindow then
          local buf = vim.api.nvim_win_get_buf(win)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          -- Close the preview window
          vim.api.nvim_win_close(win, true)

          if #lines == 0 or (#lines == 1 and lines[1] == "") then
            vim.notify("No hunk at cursor", vim.log.levels.WARN)
            return
          end

          -- Open in a floating window
          local float_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
          vim.bo[float_buf].filetype = "diff"
          vim.bo[float_buf].bufhidden = "wipe"

          local width = math.min(80, vim.o.columns - 8)
          local height = math.min(#lines, math.floor(vim.o.lines * 0.4))
          local float_win = vim.api.nvim_open_win(float_buf, true, {
            relative = "cursor",
            row = 1,
            col = 0,
            width = width,
            height = height,
            style = "minimal",
            border = "rounded",
            title = " Hunk Preview ",
            title_pos = "center",
          })

          -- Close with q or Esc
          vim.keymap.set("n", "q", function() vim.api.nvim_win_close(float_win, true) end, { buffer = float_buf })
          vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(float_win, true) end, { buffer = float_buf })
          return
        end
      end
      vim.notify("No hunk at cursor", vim.log.levels.WARN)
    end, { desc = "Signify: Preview hunk (floating)" })

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
