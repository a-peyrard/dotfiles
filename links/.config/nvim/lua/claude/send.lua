-- Claude send module — send prompts to Claude Code in adjacent tmux pane
-- Keymaps: <leader>cc (interactive), <leader>ce/cr/ct/cd (quick), <leader>cx (diagnostic), <leader>cp (picker)

local M = {}

local send_ns = vim.api.nvim_create_namespace('claude_send')

M.templates = {
  explain = "Explain this code:",
  refactor = "Refactor this code for clarity and maintainability:",
  review = "Review this code for bugs, edge cases, and improvements:",
  test = "Write tests for this code:",
  doc = "Add documentation comments to this code:",
  fix = "Find and fix bugs in this code:",
  optimize = "Optimize this code for performance:",
}

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'ClaudeSendBorder', { fg = '#7aa2f7', bg = 'NONE', default = true })
  vim.api.nvim_set_hl(0, 'ClaudeSendTitle', { fg = '#7aa2f7', bold = true, default = true })
  vim.api.nvim_set_hl(0, 'ClaudeSendFloat', { bg = '#1a1b26', default = true })
end

local function_types = {
  function_definition = true, function_declaration = true, function_item = true,
  class_definition = true, decorated_definition = true,
  impl_item = true, struct_item = true,
  method_definition = true, method_declaration = true,
}

-- ========================================================================
-- Pane targeting (resolved by nvc via UUID session files)
-- ========================================================================

-- ========================================================================
-- Send
-- ========================================================================

---@param text string
---@param opts? { no_submit?: boolean }
function M.send(text, opts)
  opts = opts or {}
  local tmpfile = "/tmp/nvc-send-nvim-" .. vim.fn.getpid() .. ".txt"
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Failed to write temp file", vim.log.levels.ERROR)
    return
  end
  f:write(text)
  f:close()

  local cmd = { "nvc", "send", "--file", tmpfile }
  if opts.no_submit then
    table.insert(cmd, "--no-submit")
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      os.remove(tmpfile)
      vim.schedule(function()
        if code == 0 then
          vim.notify("Sent to Claude", vim.log.levels.INFO)
        else
          vim.notify("Failed to send to Claude (exit " .. code .. ")", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

-- ========================================================================
-- Context gathering
-- ========================================================================

local function rel_path_for(file)
  if not vim.uv.cwd() then
    pcall(vim.cmd, "cd " .. vim.env.HOME)
  end
  local ok, repo_root = pcall(vim.fs.root, file, ".hg")
  if not ok then repo_root = nil end
  if not repo_root then
    ok, repo_root = pcall(vim.fs.root, file, ".git")
    if not ok then repo_root = nil end
  end
  if repo_root and repo_root ~= "" then
    return file:sub(#repo_root + 2)
  end
  return file
end

---@param visual boolean
---@return { file: string, location: string, code: string, start_line: number, end_line: number }
local function gather_context(visual)
  local file = vim.fn.expand("%:p")
  local rel = rel_path_for(file)

  local start_line, end_line
  if visual then
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
  else
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  local buf_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(buf_lines, "\n")

  local location
  if start_line == end_line then
    location = rel .. ":" .. start_line
  else
    location = rel .. ":" .. start_line .. "-" .. end_line
  end

  return { file = rel, location = location, code = code, start_line = start_line, end_line = end_line }
end

--- Find the enclosing function/class via treesitter and return its range
---@return { file: string, location: string, code: string, start_line: number, end_line: number }|nil
local function gather_function_context()
  local file = vim.fn.expand("%:p")
  local rel = rel_path_for(file)
  local cursor_line = vim.fn.line(".")

  vim.cmd("normal! ^")
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if ok and parser then parser:parse() end

  local node = vim.treesitter.get_node()
  while node and not function_types[node:type()] do
    node = node:parent()
  end

  if not node then return nil end

  local sr, _, er, _ = node:range()
  local start_line = sr + 1
  local end_line = er + 1
  local buf_lines = vim.api.nvim_buf_get_lines(0, sr, er + 1, false)
  local code = table.concat(buf_lines, "\n")
  local location = rel .. ":" .. start_line .. "-" .. end_line

  -- Restore cursor
  vim.api.nvim_win_set_cursor(0, { cursor_line, 0 })

  return { file = rel, location = location, code = code, start_line = start_line, end_line = end_line }
end

--- Gather context with N lines of surrounding padding
---@param visual boolean
---@param padding number
---@return { file: string, location: string, code: string, start_line: number, end_line: number }
local function gather_context_padded(visual, padding)
  local ctx = gather_context(visual)
  local total_lines = vim.api.nvim_buf_line_count(0)
  local padded_start = math.max(1, ctx.start_line - padding)
  local padded_end = math.min(total_lines, ctx.end_line + padding)

  local buf_lines = vim.api.nvim_buf_get_lines(0, padded_start - 1, padded_end, false)
  ctx.code = table.concat(buf_lines, "\n")
  ctx.location = ctx.file .. ":" .. padded_start .. "-" .. padded_end
  ctx.start_line = padded_start
  ctx.end_line = padded_end
  return ctx
end

--- Build a context header so Claude knows this comes from nvim
local function nvim_context_header()
  local file = vim.fn.expand("%:p")
  local rel = rel_path_for(file)
  local ft = vim.bo.filetype or ""
  local line = vim.fn.line(".")
  local buf_count = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= "" then
      buf_count = buf_count + 1
    end
  end
  local cwd = vim.fn.getcwd()
  local cwd_rel = rel_path_for(cwd)
  if cwd_rel == cwd then cwd_rel = cwd end

  local parts = { "[nvim" }
  if cwd_rel ~= "" then table.insert(parts, " cwd:" .. cwd_rel) end
  table.insert(parts, " buf:" .. rel .. ":" .. line)
  if ft ~= "" then table.insert(parts, " (" .. ft .. ")" ) end
  if buf_count > 1 then table.insert(parts, " | " .. buf_count .. " buffers") end
  table.insert(parts, "]")
  return table.concat(parts, "")
end

---@param prompt string
---@param ctx table
---@return string
local function format_prompt(prompt, ctx)
  local header = nvim_context_header()
  if ctx.code == "" then
    return header .. "\n\n" .. prompt
  end
  local ft = vim.bo.filetype or ""
  return string.format("%s\n\n%s\n\n%s\n```%s\n%s\n```", header, prompt, ctx.location, ft, ctx.code)
end

-- ========================================================================
-- Highlights
-- ========================================================================

local function set_selection_highlight(bufnr, start_line, end_line)
  vim.api.nvim_buf_clear_namespace(bufnr, send_ns, 0, -1)
  for line = start_line - 1, end_line - 1 do
    vim.api.nvim_buf_set_extmark(bufnr, send_ns, line, 0, { line_hl_group = 'Visual' })
  end
end

function M.clear()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      vim.api.nvim_buf_clear_namespace(b, send_ns, 0, -1)
    end
  end
end

-- ========================================================================
-- Interactive prompt
-- ========================================================================

---@param visual boolean
---@param opts? { no_submit?: boolean }
function M.prompt_and_send(visual, opts)
  opts = opts or {}
  local ctx = gather_context(visual)
  local source_buf = vim.fn.bufnr()

  if visual then
    set_selection_highlight(source_buf, vim.fn.line("'<"), vim.fn.line("'>"))
  end

  setup_highlights()

  local input_buf = vim.api.nvim_create_buf(false, true)
  local win_width = math.min(80, vim.api.nvim_win_get_width(0) - 10)
  local input_win = vim.api.nvim_open_win(input_buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = win_width,
    height = 5,
    style = "minimal",
    border = "rounded",
    title = " 󰚩 Claude ",
    title_pos = "left",
    footer = " " .. ctx.location .. "  C-s send  q cancel ",
    footer_pos = "left",
  })
  vim.bo[input_buf].buftype = "nofile"
  vim.bo[input_buf].filetype = "markdown"
  vim.wo[input_win].wrap = true
  vim.wo[input_win].linebreak = true
  vim.wo[input_win].winblend = 10
  vim.api.nvim_win_set_option(input_win, 'winhighlight', 'FloatBorder:ClaudeSendBorder,FloatTitle:ClaudeSendTitle,FloatFooter:ClaudeSendBorder,NormalFloat:ClaudeSendFloat')
  vim.cmd("startinsert")

  local function do_send()
    local input_lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
    while #input_lines > 0 and input_lines[#input_lines] == "" do
      table.remove(input_lines)
    end
    local prompt = table.concat(input_lines, "\n")
    vim.api.nvim_win_close(input_win, true)
    vim.cmd("stopinsert")
    if prompt == "" then return end

    local text = format_prompt(prompt, ctx)
    M.send(text, { no_submit = opts.no_submit })
  end

  local function do_cancel()
    vim.api.nvim_win_close(input_win, true)
  end

  vim.keymap.set({ "i", "n" }, "<C-s>", do_send, { buffer = input_buf, desc = "Send to Claude" })
  vim.keymap.set("n", "q", do_cancel, { buffer = input_buf, desc = "Cancel" })
end

-- ========================================================================
-- Quick send
-- ========================================================================

---@param template_name string
---@param visual boolean
function M.quick_send(template_name, visual)
  local prompt = M.templates[template_name] or template_name
  local ctx

  if visual then
    ctx = gather_context(true)
    set_selection_highlight(vim.fn.bufnr(), ctx.start_line, ctx.end_line)
  else
    ctx = gather_function_context()
    if not ctx then
      ctx = gather_context(false)
    else
      set_selection_highlight(vim.fn.bufnr(), ctx.start_line, ctx.end_line)
    end
  end

  local text = format_prompt(prompt, ctx)
  M.send(text)
end

-- ========================================================================
-- Send diagnostic under cursor
-- ========================================================================

function M.send_diagnostic()
  local cursor_line = vim.fn.line(".") - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = cursor_line })

  if #diagnostics == 0 then
    vim.notify("No diagnostics at cursor", vim.log.levels.WARN)
    return
  end

  local diag = diagnostics[1]
  local severity = vim.diagnostic.severity[diag.severity] or "ERROR"
  local source = diag.source and (" [" .. diag.source .. "]") or ""

  local ctx = gather_function_context() or gather_context_padded(false, 5)
  set_selection_highlight(vim.fn.bufnr(), ctx.start_line, ctx.end_line)

  local prompt = string.format("Fix this %s%s: %s", severity, source, diag.message)
  local text = format_prompt(prompt, ctx)
  M.send(text)
end

-- ========================================================================
-- Telescope template picker
-- ========================================================================

function M.template_picker(visual, ctx)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local conf = require("telescope.config").values

  local entries = {}
  for name, prompt in pairs(M.templates) do
    table.insert(entries, { name = name, prompt = prompt })
  end
  table.sort(entries, function(a, b) return a.name < b.name end)

  if not ctx then
    if visual then
      ctx = gather_context(true)
    else
      ctx = gather_function_context() or gather_context(false)
    end
  end

  pickers.new({}, {
    prompt_title = "Send to Claude",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name .. "  " .. entry.prompt,
          ordinal = entry.name .. " " .. entry.prompt,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local text = format_prompt(selection.value.prompt, ctx)
          M.send(text)
        end
      end)
      return true
    end,
  }):find()
end

-- ========================================================================
-- Keymaps
-- ========================================================================

-- Which-key group
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
  wk.add({ { "<leader>c", group = "Claude" } })
end

-- Interactive prompt
vim.keymap.set("n", "<leader>cc", function() M.prompt_and_send(false) end,
  { desc = "Ask Claude (cursor context)" })
vim.keymap.set("v", "<leader>cc", function()
  vim.cmd("normal! \27")
  M.prompt_and_send(true)
end, { desc = "Ask Claude (selection)" })

-- Quick templates — visual: send selection, normal: send enclosing function
vim.keymap.set("n", "<leader>ce", function() M.quick_send("explain", false) end,
  { desc = "Claude: explain function" })
vim.keymap.set("v", "<leader>ce", function()
  vim.cmd("normal! \27")
  M.quick_send("explain", true)
end, { desc = "Claude: explain selection" })

vim.keymap.set("n", "<leader>cr", function() M.quick_send("refactor", false) end,
  { desc = "Claude: refactor function" })
vim.keymap.set("v", "<leader>cr", function()
  vim.cmd("normal! \27")
  M.quick_send("refactor", true)
end, { desc = "Claude: refactor selection" })

vim.keymap.set("n", "<leader>ct", function() M.quick_send("test", false) end,
  { desc = "Claude: write tests for function" })
vim.keymap.set("v", "<leader>ct", function()
  vim.cmd("normal! \27")
  M.quick_send("test", true)
end, { desc = "Claude: write tests" })

vim.keymap.set("n", "<leader>cd", function() M.quick_send("doc", false) end,
  { desc = "Claude: add docs to function" })
vim.keymap.set("v", "<leader>cd", function()
  vim.cmd("normal! \27")
  M.quick_send("doc", true)
end, { desc = "Claude: add docs" })

-- Fix diagnostic under cursor
vim.keymap.set("n", "<leader>cx", M.send_diagnostic,
  { desc = "Claude: fix diagnostic" })

-- Template picker
vim.keymap.set("n", "<leader>cp", function() M.template_picker(false) end,
  { desc = "Claude: template picker" })
vim.keymap.set("v", "<leader>cp", function()
  vim.cmd("normal! \27")
  M.template_picker(true)
end, { desc = "Claude: template picker" })

-- No auto-submit
vim.keymap.set("n", "<leader>cC", function()
  M.prompt_and_send(false, { no_submit = true })
end, { desc = "Ask Claude (no auto-submit)" })
vim.keymap.set("v", "<leader>cC", function()
  vim.cmd("normal! \27")
  M.prompt_and_send(true, { no_submit = true })
end, { desc = "Ask Claude (no auto-submit)" })

return M
