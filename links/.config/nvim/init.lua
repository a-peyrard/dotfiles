-- Set leader key to Space BEFORE loading anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load options and environment setup first
require("config.options")

-- Load general keybindings
require("config.keymaps")

-- Bootstrap lazy.nvim plugin manager
require("config.lazy")

-- Load private/work configuration if it exists
-- Private config location: ~/.config/nvim.private/init.lua
local private_config = vim.fn.expand('~/.config/nvim.private/init.lua')
if vim.fn.filereadable(private_config) == 1 then
  dofile(private_config)
end
