-- General keybindings (not plugin-specific)

-- Exit insert mode with jk
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

-- Clear search highlighting
vim.keymap.set('n', '<leader>/', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
