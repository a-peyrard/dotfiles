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

-- UUID-based session pairing for nvc.
-- If spawned by nvc, NVC_SESSION_ID is set. Otherwise generate one.
-- Socket: /tmp/nvim-claude-$USER-$UUID.sock
-- Lookup: /tmp/nvc-me-$TMUX_PANE → UUID (so nvc can find us)
if vim.env.TMUX_PANE then
  local session_id = vim.env.NVC_SESSION_ID
  if not session_id or session_id == "" then
    local f = io.open("/dev/urandom", "rb")
    if f then
      local bytes = f:read(4)
      f:close()
      session_id = bytes:gsub(".", function(c) return string.format("%02x", string.byte(c)) end)
    else
      session_id = string.format("%08x", math.random(0, 0xFFFFFFFF))
    end
    vim.env.NVC_SESSION_ID = session_id
  end

  local sock = "/tmp/nvim-claude-" .. (vim.env.USER or "unknown") .. "-" .. session_id .. ".sock"
  pcall(vim.fn.serverstart, sock)

  local mf = io.open("/tmp/nvc-me-" .. vim.env.TMUX_PANE, "w")
  if mf then mf:write(session_id); mf:close() end
end

-- Load private/work configuration if it exists
-- Private config location: ~/.config/nvim.private/init.lua
local private_config = vim.fn.expand('~/.config/nvim.private/init.lua')
if vim.fn.filereadable(private_config) == 1 then
  dofile(private_config)
end
