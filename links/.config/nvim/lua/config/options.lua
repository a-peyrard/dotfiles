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
vim.opt.signcolumn = "yes"      -- Always show sign column (prevents text jumping)

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

-- Show invisible characters (optional - uncomment if you want to see them)
-- vim.opt.list = true
-- vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Configure diagnostic floating windows with borders (matches completion style)
vim.diagnostic.config({
  float = {
    border = "rounded",  -- Rounded borders for diagnostic floating windows
    source = "always",   -- Always show the source (e.g., "rust-analyzer", "pyright")
    header = "",         -- No header
    prefix = "",         -- No prefix
    focusable = true,    -- Allow entering the window with Ctrl+w w
  },
})

