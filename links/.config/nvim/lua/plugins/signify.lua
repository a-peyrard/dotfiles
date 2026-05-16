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
      diff_base = nil,
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

    local function set_review_mode(enabled, rev, base)
      rev = rev or "."
      review_state.review_mode = enabled
      review_state.current_rev = rev
      review_state.diff_base = base

      if enabled then
        local diff_base = base or (rev .. "^")
        set_vcs_cmds(
          string.format("hg --config alias.diff=diff diff --color=never --nodates -U0 --rev %s -- %%f", diff_base),
          string.format("hg cat --rev %s %%f", diff_base)
        )
        vim.notify(string.format("Review mode ON (diff against %s)", diff_base))
      else
        set_vcs_cmds(review_state.normal_cmd, review_state.normal_diffmode_cmd)
        vim.notify("Review mode OFF")
      end

      vim.cmd("SignifyRefresh")
    end

    review_state.set_review_mode = set_review_mode

    review_state.light_review = function(mode, rev, base)
      require("lazy").load({ plugins = {"vim-signify"} })
      if mode == "off" or mode == "working_tree" then
        if review_state.review_mode then set_review_mode(false) end
      elseif mode == "amend" then
        set_review_mode(true, rev or ".", base)
      elseif mode == "toggle" then
        if review_state.review_mode and review_state.current_rev == rev then
          set_review_mode(false)
        else
          set_review_mode(true, rev, base)
        end
      else
        set_review_mode(true, rev, base)
      end
    end

    vim.keymap.set("n", "<leader>hc", function()
      set_review_mode(not review_state.review_mode)
    end, { desc = "Signify: Toggle review mode (diff .^)" })

    -- Additional keymaps for signify-specific features
    vim.keymap.set("n", "<leader>hd", "<cmd>SignifyDiff<cr>", { desc = "Signify: Diff this" })

    -- Override signify's popup to use a bordered floating window.
    -- SignifyHunkDiff is async (diff runs in callback), so we can't intercept
    -- after the call — we override the popup function signify calls internally.
    local popup_win = nil

    local ns_hunk = vim.api.nvim_create_namespace("signify_hunk_preview")
    vim.api.nvim_set_hl(0, "HunkPreviewDelete", { bg = "#3a2020" })
    vim.api.nvim_set_hl(0, "HunkPreviewAdd", { bg = "#203a20" })
    vim.api.nvim_set_hl(0, "HunkPreviewBorder", { fg = "#98c379", bg = "NONE", default = true })
    vim.api.nvim_set_hl(0, "HunkPreviewTitle", { fg = "#98c379", bold = true, default = true })
    vim.api.nvim_set_hl(0, "HunkPreviewFloat", { bg = "#1a1b26", default = true })

    local CONTEXT_LINES = 3

    _G._signify_popup_create = function(hunkdiff)
      if popup_win and vim.api.nvim_win_is_valid(popup_win) then
        vim.api.nvim_win_close(popup_win, true)
      end

      if #hunkdiff == 0 then return end

      -- Re-run diff with context to get full hunk with surrounding code
      local file = vim.fn.expand("%:p")
      local repo_root = vim.fs.root(file, ".hg")
      if not repo_root then return end

      local rel_path = file:sub(#repo_root + 2)
      local rev_arg = {}
      if review_state.review_mode then
        local base = review_state.diff_base or (review_state.current_rev .. "^")
        rev_arg = { "--rev", base }
      end

      local cmd = { "hg", "--config", "alias.diff=diff", "diff",
        "--color=never", "--nodates", "-U" .. CONTEXT_LINES }
      for _, a in ipairs(rev_arg) do table.insert(cmd, a) end
      table.insert(cmd, "--")
      table.insert(cmd, rel_path)

      local result = vim.system(cmd, { text = true, cwd = repo_root }):wait()
      if result.code ~= 0 or not result.stdout then return end

      -- Find the hunk at cursor position
      local cur_line = vim.fn.line(".")
      local matched_hunk = nil

      -- Parse all hunks, find the one containing cursor
      local all_lines = vim.split(result.stdout, "\n", { plain = true })
      local hunks = {}
      local current_hunk = nil

      for _, line in ipairs(all_lines) do
        local os, oc, ns, nc = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
        if os then
          current_hunk = {
            old_start = tonumber(os),
            old_count = tonumber(oc) or 1,
            new_start = tonumber(ns),
            new_count = tonumber(nc) or 1,
            lines = {},
          }
          table.insert(hunks, current_hunk)
        elseif current_hunk and (line:match("^[%+%- ]") or line == "") then
          table.insert(current_hunk.lines, line)
        end
      end

      for _, hunk in ipairs(hunks) do
        local ns, nc = hunk.new_start, hunk.new_count
        if nc == 0 then
          if cur_line == ns then matched_hunk = hunk; break end
        else
          if cur_line >= ns and cur_line < ns + nc then matched_hunk = hunk; break end
        end
      end

      if not matched_hunk then return end

      -- Build display: strip +/- prefixes, track line types for highlighting
      local display_lines = {}
      local line_types = {} -- "add", "del", or "ctx"

      for _, line in ipairs(matched_hunk.lines) do
        if line:match("^%+") then
          table.insert(display_lines, line:sub(2))
          table.insert(line_types, "add")
        elseif line:match("^%-") then
          table.insert(display_lines, line:sub(2))
          table.insert(line_types, "del")
        else
          -- context line (leading space)
          table.insert(display_lines, line:sub(2))
          table.insert(line_types, "ctx")
        end
      end

      if #display_lines == 0 then return end

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)

      local source_ft = vim.bo.filetype
      if source_ft and source_ft ~= "" then vim.bo[buf].filetype = source_ft end
      vim.bo[buf].bufhidden = "wipe"

      local max_line_len = 0
      for _, l in ipairs(display_lines) do
        max_line_len = math.max(max_line_len, #l)
      end
      local width = math.min(math.max(max_line_len + 4, 40), vim.o.columns - 8)
      local height = math.min(#display_lines, math.floor(vim.o.lines * 0.4))

      popup_win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor", row = 1, col = 0,
        width = width, height = height,
        style = "minimal", border = "rounded",
        title = " Hunk Diff ", title_pos = "center",
      })
      vim.wo[popup_win].winblend = 10
      vim.api.nvim_win_set_option(popup_win, 'winhighlight', 'NormalFloat:HunkPreviewFloat,FloatBorder:HunkPreviewBorder,FloatTitle:HunkPreviewTitle')

      -- Apply red/green background tints (syntax highlighting shows through)
      for i, kind in ipairs(line_types) do
        if kind == "del" or kind == "add" then
          vim.api.nvim_buf_set_extmark(buf, ns_hunk, i - 1, 0, {
            end_row = i,
            hl_group = kind == "del" and "HunkPreviewDelete" or "HunkPreviewAdd",
            hl_eol = true,
          })
        end
      end

      vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(popup_win) then vim.api.nvim_win_close(popup_win, true) end
      end, { buffer = buf })
      vim.keymap.set("n", "<Esc>", function()
        if vim.api.nvim_win_is_valid(popup_win) then vim.api.nvim_win_close(popup_win, true) end
      end, { buffer = buf })
    end

    -- Override lives in autoload/sy/util.vim (E746 requires matching script name).
    -- Force-load it now so it takes precedence over signify's version.
    vim.cmd("runtime autoload/sy/util.vim")

    vim.keymap.set("n", "<leader>hp", "<cmd>SignifyHunkDiff<cr>",
      { desc = "Signify: Preview hunk (floating)" })

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
