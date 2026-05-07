-- Interactive diff review — Claude proposes changes, user cherry-picks
-- Opens side-by-side diff with hunk-by-hunk accept/discard and counter
-- Results sent back to Claude via nvc send

local M = {}

-- Global state for lualine integration
vim.g.diff_review_active = false
vim.g.diff_review_remaining = 0

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'DiffReviewCounter', { fg = '#7aa2f7', bold = true, default = true })
end

--- Count remaining diff hunks by scanning for diff-highlighted lines
---@param bufnr number
---@return number
local function count_hunks(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local hunks = 0
  local in_hunk = false

  for lnum = 1, line_count do
    local hl = vim.fn.diff_hlID(lnum, 1)
    if hl > 0 then
      if not in_hunk then
        hunks = hunks + 1
        in_hunk = true
      end
    else
      in_hunk = false
    end
  end

  return hunks
end

--- Jump to next hunk if one exists
local function jump_next_hunk()
  local ok = pcall(vim.cmd, "normal! ]c")
  if not ok then
    pcall(vim.cmd, "normal! gg]c")
  end
end

--- Open an interactive diff review
---@param file string Absolute path to the original file
---@param proposed_file string Path to temp file with proposed content
---@param review_id string Unique ID for this review session
function M.open(file, proposed_file, review_id)
  setup_highlights()

  local rel_path = file
  local repo_root = vim.fs.root(file, ".hg") or vim.fs.root(file, ".git") or ""
  if repo_root ~= "" then
    rel_path = file:sub(#repo_root + 2)
  end

  local original_buf = vim.fn.bufnr(file)
  if original_buf == -1 or not vim.api.nvim_buf_is_loaded(original_buf) then
    vim.cmd("edit " .. vim.fn.fnameescape(file))
    original_buf = vim.fn.bufnr()
  else
    vim.api.nvim_set_current_buf(original_buf)
  end

  local original_win = vim.api.nvim_get_current_win()

  vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(proposed_file))
  local proposed_win = vim.api.nvim_get_current_win()
  local proposed_buf = vim.fn.bufnr()

  vim.api.nvim_buf_set_name(proposed_buf, file .. " (proposed)")
  vim.bo[proposed_buf].buftype = "nofile"
  vim.bo[proposed_buf].filetype = vim.bo[original_buf].filetype

  vim.api.nvim_set_current_win(original_win)

  -- Show context around hunks — diff mode folds unchanged lines at foldlevel 0
  vim.wo[original_win].foldlevel = 99
  vim.wo[proposed_win].foldlevel = 99

  pcall(vim.cmd, "normal! gg]c")

  local function close_review()
    vim.g.diff_review_active = false
    vim.g.diff_review_remaining = 0

    if vim.api.nvim_win_is_valid(proposed_win) then
      vim.api.nvim_win_close(proposed_win, true)
    end
    if vim.api.nvim_buf_is_valid(proposed_buf) then
      vim.api.nvim_buf_delete(proposed_buf, { force = true })
    end
    vim.cmd("diffoff")
    os.remove(proposed_file)
    os.remove("/tmp/nvc-diff-review-" .. review_id .. ".lua")
  end

  local function send_result(accepted)
    close_review()

    local status = accepted and "ACCEPTED" or "REJECTED"
    local msg = string.format("[diff-review] %s %s", status, rel_path)

    vim.notify("Diff " .. (accepted and "accepted" or "rejected") .. ": " .. rel_path,
      vim.log.levels.INFO)

    local send = require("claude.send")
    send.send(msg)
  end

  local function show_counter()
    vim.cmd("diffupdate")
    local remaining = count_hunks(original_buf)

    vim.g.diff_review_remaining = remaining

    if remaining == 0 then
      vim.notify("All hunks addressed — <leader>aa to save, <leader>ad to discard",
        vim.log.levels.INFO)
    else
      local label = remaining == 1 and "hunk" or "hunks"
      vim.notify(string.format("%d %s remaining", remaining, label), vim.log.levels.INFO)
    end
  end

  local function accept_hunk()
    -- Pull proposed change into original (always from original window)
    local cur_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(original_win)
    vim.cmd("diffget " .. proposed_buf)
    if cur_win ~= original_win and vim.api.nvim_win_is_valid(cur_win) then
      vim.api.nvim_set_current_win(cur_win)
    end
    vim.schedule(function()
      show_counter()
      jump_next_hunk()
    end)
  end

  local function discard_hunk()
    -- Keep original, push to proposed so both match (hunk disappears)
    local cur_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(original_win)
    vim.cmd("diffput " .. proposed_buf)
    if cur_win ~= original_win and vim.api.nvim_win_is_valid(cur_win) then
      vim.api.nvim_set_current_win(cur_win)
    end
    vim.schedule(function()
      show_counter()
      jump_next_hunk()
    end)
  end

  local function accept_all()
    vim.api.nvim_set_current_win(original_win)

    local proposed_lines = vim.api.nvim_buf_get_lines(proposed_buf, 0, -1, false)
    vim.api.nvim_buf_set_lines(original_buf, 0, -1, false, proposed_lines)
    vim.api.nvim_buf_call(original_buf, function() vim.cmd("write") end)

    send_result(true)
  end

  local function save_current()
    vim.api.nvim_set_current_win(original_win)
    vim.api.nvim_buf_call(original_buf, function() vim.cmd("write") end)
    send_result(true)
  end

  local function reject_all()
    send_result(false)
  end

  for _, buf in ipairs({ original_buf, proposed_buf }) do
    vim.keymap.set("n", "do", accept_hunk, { buffer = buf, desc = "Accept this hunk" })
    vim.keymap.set("n", "dp", discard_hunk, { buffer = buf, desc = "Discard this hunk" })
    vim.keymap.set("n", "<leader>aa", save_current, { buffer = buf, desc = "Save and accept" })
    vim.keymap.set("n", "<leader>ad", reject_all, { buffer = buf, desc = "Reject all changes" })
    vim.keymap.set("n", "<leader>aA", accept_all, { buffer = buf, desc = "Accept all proposed" })
  end

  local initial_hunks = count_hunks(original_buf)
  vim.g.diff_review_active = true
  vim.g.diff_review_remaining = initial_hunks

  local label = initial_hunks == 1 and "hunk" or "hunks"
  vim.notify(string.format(
    "Diff review: %s — %d %s  [do accept · dp discard · <leader>aa save · <leader>ad reject]",
    rel_path, initial_hunks, label), vim.log.levels.INFO)
end

return M
