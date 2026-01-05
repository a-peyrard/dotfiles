-- Set leader key to Space BEFORE loading anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load options and environment setup first
require("config.options")

-- Load general keybindings
require("config.keymaps")

-- Conditional loading: VSCode vs Full Neovim
if vim.g.vscode then
  -- VSCode mode: load minimal plugin config
  require("vscode_config")
else
  -- Full Neovim mode: load all plugins
  require("config.lazy")
end

-- Load private/work configuration if it exists
-- Private config location: ~/.config/nvim.private/init.lua
local private_config = vim.fn.expand('~/.config/nvim.private/init.lua')
if vim.fn.filereadable(private_config) == 1 then
  dofile(private_config)
end
