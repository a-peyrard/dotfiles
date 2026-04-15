-- General keybindings (not plugin-specific)

-- Exit insert mode with jk
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

-- Clear search highlighting
vim.keymap.set('n', '<leader>/', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

-- Copy file path to clipboard
vim.keymap.set('n', '<leader>yf', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify(path, vim.log.levels.INFO)
end, { desc = 'Copy absolute file path' })
