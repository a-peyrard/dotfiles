-- Claude highlight module — extracted from nvc bash script
-- Called via: require("claude.highlight").highlight(queries)
--             require("claude.highlight").clear()

local M = {}

M.ns = vim.api.nvim_create_namespace('claude_highlight')

local block_types = {
  function_definition = true, class_definition = true,
  for_statement = true, while_statement = true, if_statement = true,
  with_statement = true, try_statement = true,
  import_statement = true, import_from_statement = true, decorated_definition = true,
  function_declaration = true, function_item = true,
  impl_item = true, struct_item = true, enum_item = true,
  for_expression = true, loop_expression = true, match_expression = true, use_declaration = true,
}

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'ClaudeHighlight', { bg = '#292e42', default = true })
  vim.api.nvim_set_hl(0, 'ClaudeHLSign', { fg = '#7aa2f7', bg = 'NONE', default = true })
  vim.fn.sign_define('ClaudeHL', { text = '▍', texthl = 'ClaudeHLSign' })
end

local function apply_highlight(bufnr, sr, er)
  for line = sr, er do
    vim.api.nvim_buf_set_extmark(bufnr, M.ns, line, 0, { line_hl_group = 'ClaudeHighlight' })
    vim.fn.sign_place(0, 'claude_signs', 'ClaudeHL', bufnr, { lnum = line + 1 })
  end
end

local function get_regions()
  local extmarks = vim.api.nvim_buf_get_extmarks(0, M.ns, 0, -1, {})
  if #extmarks == 0 then return {} end
  local lines = {}
  for _, m in ipairs(extmarks) do lines[#lines + 1] = m[2] end
  table.sort(lines)
  local regions = {}
  local cs, ce = nil, nil
  for _, l in ipairs(lines) do
    if not cs then cs, ce = l, l
    elseif l == ce + 1 then ce = l
    else regions[#regions + 1] = cs; cs, ce = l, l end
  end
  if cs then regions[#regions + 1] = cs end
  return regions
end

--- Clear all highlights in all buffers
function M.clear()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      vim.api.nvim_buf_clear_namespace(b, M.ns, 0, -1)
    end
  end
  vim.fn.sign_unplace('claude_signs')
  vim.notify('Claude highlights cleared')
end

--- Apply highlights from a list of queries
--- @param queries table[] List of {mode, file, line, line_end}
function M.highlight(queries)
  setup_highlights()

  local first_line = nil
  local seen_files = {}

  -- Open all files first
  for _, q in ipairs(queries) do
    if not seen_files[q.file] then
      seen_files[q.file] = true
      vim.cmd('edit ' .. q.file)
    end
  end

  -- Apply highlights
  for _, q in ipairs(queries) do
    if vim.fn.expand('%:p') ~= q.file then vim.cmd('edit ' .. q.file) end
    local bufnr = vim.fn.bufnr()

    if q.mode == 'lines' and q.line_end > 0 then
      apply_highlight(bufnr, q.line - 1, q.line_end - 1)
      if not first_line then first_line = q.line end

    elseif q.mode == 'function' or q.mode == 'block' then
      if q.line > 0 then vim.cmd(tostring(q.line)); vim.cmd('normal! ^') end
      local ok, parser = pcall(vim.treesitter.get_parser, 0)
      if ok and parser then parser:parse() end
      local node = vim.treesitter.get_node()
      if q.mode == 'function' then
        while node and node:type() ~= 'function_definition'
            and node:type() ~= 'function_declaration'
            and node:type() ~= 'function_item' do
          node = node:parent()
        end
      else
        while node and not block_types[node:type()] do node = node:parent() end
      end
      if node then
        local sr, _, er, _ = node:range()
        apply_highlight(bufnr, sr, er)
        if not first_line then first_line = sr + 1 end
      end
    end
  end

  -- Navigate to first highlight
  if first_line then
    if vim.fn.expand('%:p') ~= queries[1].file then vim.cmd('edit ' .. queries[1].file) end
    vim.api.nvim_win_set_cursor(0, { first_line, 0 })
    vim.cmd('normal! zz')
  end
end

-- Navigation keymaps (set once on first require)
vim.keymap.set('n', ']c', function()
  local r = get_regions(); if #r == 0 then return end
  local cur = vim.api.nvim_win_get_cursor(0)[1] - 1
  for _, s in ipairs(r) do
    if s > cur then vim.api.nvim_win_set_cursor(0, { s + 1, 0 }); vim.cmd('normal! zz'); return end
  end
  vim.api.nvim_win_set_cursor(0, { r[1] + 1, 0 }); vim.cmd('normal! zz')
end, { desc = 'Next highlight' })

vim.keymap.set('n', '[c', function()
  local r = get_regions(); if #r == 0 then return end
  local cur = vim.api.nvim_win_get_cursor(0)[1] - 1
  for i = #r, 1, -1 do
    if r[i] < cur then vim.api.nvim_win_set_cursor(0, { r[i] + 1, 0 }); vim.cmd('normal! zz'); return end
  end
  vim.api.nvim_win_set_cursor(0, { r[#r] + 1, 0 }); vim.cmd('normal! zz')
end, { desc = 'Prev highlight' })

vim.keymap.set('n', '<leader>hx', function()
  M.clear()
end, { desc = 'Clear Claude highlights' })

return M
