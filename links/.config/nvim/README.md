# Neovim Configuration

This is a modular Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. It targets Python and Rust development with LSP support, autocompletion, syntax highlighting, and fuzzy finding.

## Directory Structure

```
~/.config/nvim/                   # Main versioned config (symlinked from dotfiles)
├── init.lua                      # Entry point - sets leader key, loads config, sources private config
├── lazy-lock.json               # Plugin version lockfile
├── CLAUDE.md                     # Detailed configuration guide for Claude Code
├── nvim-cheatsheet.md           # Comprehensive keybinding reference
└── lua/
    ├── config/
    │   ├── lazy.lua             # Bootstrap lazy.nvim
    │   └── options.lua          # Vim options, PATH config, diagnostics
    └── plugins/                 # One file per plugin/group
        ├── colorscheme.lua      # tokyonight theme
        ├── lsp.lua              # Mason + LSP setup
        ├── treesitter.lua       # Syntax highlighting
        ├── completion.lua       # nvim-cmp autocompletion
        ├── telescope.lua        # Fuzzy finder
        ├── formatting.lua       # none-ls formatters/linters
        ├── navigation.lua       # leap.nvim movement
        ├── filetree.lua         # neo-tree file explorer
        ├── indent.lua           # indent guides
        ├── ui.lua               # which-key + trouble
        ├── git.lua              # gitsigns
        ├── tmux.lua             # vim-tmux-navigator
        └── test.lua             # neotest
```

## Private/Work Configuration

For work-related or proprietary configurations that shouldn't be versioned:

1. Create a separate directory: `~/.config/nvim.private/`
2. Add your private config: `~/.config/nvim.private/init.lua`
3. The main `init.lua` automatically sources this file if it exists

**Example private config structure:**
```
~/.config/nvim.private/
├── init.lua                     # Private entry point
└── lua/
    └── work/
        ├── plugins.lua          # Work-specific plugins
        ├── lsp.lua              # Company LSP servers
        └── keymaps.lua          # Proprietary keybindings
```

**Benefits of this approach:**
- ✅ Complete separation between personal and work configs
- ✅ Personal config stays versioned in dotfiles
- ✅ Work config stays local and private
- ✅ Can use the same pattern for other tools (`.tmux.private.conf`, etc.)

## Installation

This configuration is managed as part of the dotfiles repository. The installation script creates a symlink from `~/config/dotfiles/links/.config/nvim/` to `~/.config/nvim/`.

1. Run the dotfiles installer: `./install.sh`
2. Launch Neovim: `nvim`
3. Plugins will auto-install on first launch
4. LSP servers install via Mason automatically

## Key Plugins

- **lazy.nvim** - Plugin manager
- **Mason** - LSP/formatter/linter installer
- **nvim-lspconfig** - LSP configurations (rust_analyzer, pyright, lua_ls)
- **nvim-cmp** - Autocompletion
- **telescope.nvim** - Fuzzy finder
- **leap.nvim** - Fast cursor movement
- **neo-tree.nvim** - File explorer
- **which-key.nvim** - Keybinding helper

See `CLAUDE.md` for detailed documentation and `nvim-cheatsheet.md` for all keybindings.

## Quick Reference

- **Leader key:** `Space`
- **Find files:** `<leader>ff`
- **Live grep:** `<leader>fg`
- **Toggle file tree:** `<leader>e`
- **Format code:** `<leader>f`
- **Go to definition:** `gd`
- **Rename symbol:** `<leader>rn`
- **Code actions:** `<leader>ca`

Full keybinding reference: see `nvim-cheatsheet.md`
