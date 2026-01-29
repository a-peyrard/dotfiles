-- Neovim options and environment configuration

-- Add Mason binaries to PATH so formatters/linters can be found
-- This only affects the Neovim process, not your shell environment
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- ============================================================================
-- Display & UI
-- ============================================================================

-- Line numbers
vim.opt.number = true           -- Show absolute line number on current line
vim.opt.relativenumber = true   -- Show relative line numbers

-- Current line highlighting
vim.opt.cursorline = true       -- Highlight the current line
-- vim.opt.cursorcolumn = true  -- Disabled: too distracting. Using indent guides instead

-- Sign column (for git signs, LSP diagnostics, etc.)
vim.opt.signcolumn = "yes"      -- Single sign column (diagnostics take priority over VCS)

-- Better scrolling
vim.opt.scrolloff = 8           -- Keep 8 lines visible above/below cursor
vim.opt.sidescrolloff = 8       -- Keep 8 columns visible to left/right of cursor

-- True color support
vim.opt.termguicolors = true    -- Enable 24-bit RGB colors

-- Better command line
vim.opt.cmdheight = 1           -- Height of command line
vim.opt.showmode = false        -- Don't show mode (already in statusline)

-- Split behavior
vim.opt.splitright = true       -- Vertical splits open to the right
vim.opt.splitbelow = true       -- Horizontal splits open below

-- Line wrapping
vim.opt.wrap = false            -- Don't wrap lines (useful for code)
vim.opt.linebreak = true        -- If wrap is enabled, break at word boundaries

-- ============================================================================
-- Search
-- ============================================================================

vim.opt.ignorecase = true       -- Ignore case when searching
vim.opt.smartcase = true        -- Unless search contains uppercase letters
vim.opt.hlsearch = true         -- Highlight search results
vim.opt.incsearch = true        -- Show search matches as you type

-- ============================================================================
-- Editor Behavior
-- ============================================================================

-- Clipboard integration (copy/paste with system clipboard)
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard for all yank/paste operations

-- Persistent undo (undo even after closing file!)
vim.opt.undofile = true         -- Save undo history to file
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"  -- Where to save undo files

-- Backup files
vim.opt.backup = false          -- Don't create backup files
vim.opt.writebackup = false     -- Don't create backup before overwriting
vim.opt.swapfile = false        -- Don't create swap files

-- Mouse support (useful in tmux, even if you prefer keyboard)
vim.opt.mouse = "a"             -- Enable mouse in all modes

-- Better completion experience
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Hide buffers instead of closing them
vim.opt.hidden = true           -- Keep buffers open in background

-- ============================================================================
-- Performance
-- ============================================================================

vim.opt.updatetime = 250        -- Faster completion & better git signs responsiveness
vim.opt.timeoutlen = 300        -- Faster timeout for key combinations (for which-key)

-- ============================================================================
-- Indentation (Python & Rust friendly)
-- ============================================================================

vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.shiftwidth = 4          -- Indent width (4 spaces for Python, overridden per-filetype if needed)
vim.opt.tabstop = 4             -- Tab width
vim.opt.softtabstop = 4         -- Backspace removes 4 spaces
vim.opt.smartindent = true      -- Smart auto-indenting
vim.opt.autoindent = true       -- Copy indent from current line when starting new line

-- ============================================================================
-- Misc
-- ============================================================================

-- Better diff mode
vim.opt.diffopt:append("vertical")  -- Vertical diff splits

-- Show invisible characters (IntelliJ-style subtle display)
vim.opt.list = false
vim.opt.listchars = {
  tab = "▸ ",      -- Tab character
  space = "·",     -- Space character (middle dot)
  trail = "•",     -- Trailing spaces (bullet)
  nbsp = "+",      -- Non-breaking space
  eol = "¬",       -- End of line
}

-- Ensure diagnostic sign highlights have visible colors
vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#db4b4b", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e0af68", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#1abc9c", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#0db9d7", bg = "NONE" })

-- Gitsigns line number highlights (VCS changes shown in line numbers)
vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = "#98c379", bg = "NONE" })
vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = "#e5c07b", bg = "NONE" })
vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = "#e06c75", bg = "NONE" })

-- Configure diagnostic display (Neovim 0.10+ API)
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{F057}",  -- FA times-circle
      [vim.diagnostic.severity.WARN] = "\u{F071}",   -- FA exclamation-triangle
      [vim.diagnostic.severity.HINT] = "\u{F0EB}",   -- FA lightbulb
      [vim.diagnostic.severity.INFO] = "\u{F05A}",   -- FA info-circle
    },
  },
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    focusable = true,
  },
})

-- Custom diagnostic virtual text highlights (transparent background)
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#db4b4b", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#e0af68", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#0db9d7", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#1abc9c", bg = "NONE" })

-- Persist highlights on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Diagnostic sign highlights
    vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#db4b4b", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e0af68", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#1abc9c", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#0db9d7", bg = "NONE" })
    -- Diagnostic virtual text highlights
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#db4b4b", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#e0af68", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#0db9d7", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#1abc9c", bg = "NONE" })
    -- Gitsigns line number highlights
    vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = "#98c379", bg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = "#e5c07b", bg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = "#e06c75", bg = "NONE" })
  end,
})

-- ============================================================================
-- Autosave (IntelliJ-like behavior)
-- ============================================================================

-- Global variable to track autosave state
vim.g.autosave_enabled = true

-- Helper function to perform silent save
local function autosave()
  -- Only save if autosave is enabled, buffer is modified, and has a filename
  if vim.g.autosave_enabled
    and vim.bo.modified
    and vim.bo.buftype == ""
    and vim.fn.expand("%") ~= "" then
    vim.cmd("silent! write")
  end
end

-- Create autosave autocommands
local autosave_group = vim.api.nvim_create_augroup("Autosave", { clear = true })

-- Save when leaving Neovim (switching to another app)
vim.api.nvim_create_autocmd("FocusLost", {
  group = autosave_group,
  pattern = "*",
  callback = autosave,
  desc = "Autosave on focus lost",
})

-- Save when switching buffers
vim.api.nvim_create_autocmd("BufLeave", {
  group = autosave_group,
  pattern = "*",
  callback = autosave,
  desc = "Autosave on buffer leave",
})

-- Toggle autosave on/off
vim.keymap.set("n", "<leader>ua", function()
  vim.g.autosave_enabled = not vim.g.autosave_enabled
  if vim.g.autosave_enabled then
    vim.notify("Autosave enabled", vim.log.levels.INFO)
  else
    vim.notify("Autosave disabled", vim.log.levels.WARN)
  end
end, { desc = "Toggle autosave" })

-- ============================================================================
-- Keymaps
-- ============================================================================

-- Reload configuration with visual confirmation
vim.keymap.set("n", "<leader>R", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Neovim config" })

