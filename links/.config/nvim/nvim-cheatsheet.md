# Neovim Cheatsheet

Quick reference for your Neovim configuration.

## 🚀 Getting Started

### Launch Neovim
```bash
nvim                    # Open Neovim
nvim file.py           # Open specific file
nvim .                 # Open in current directory
```

### First Time Setup
```vim
:Lazy                  # Open plugin manager
:Lazy sync             # Sync/install plugins
:Mason                 # Open LSP/formatter installer
:checkhealth           # Check Neovim health
```

---

## 📝 Basic Neovim Operations

### Understanding `<leader>` Key
**`<leader>` = Spacebar** in your config!

When you see `<leader>ff`:
1. Press **Space** (the leader key)
2. Then press `f`
3. Then press `f` again

**Pro tip:** Press **Space** and wait ~300ms - which-key will show you all available commands!

Examples:
- `<leader>ff` = Space + f + f (Find Files)
- `<leader>ca` = Space + c + a (Code Actions)
- `<leader>e` = Space + e (Toggle file tree)

---

### Modes
| Key | Action |
|-----|--------|
| `i` | Insert mode (before cursor) |
| `a` | Insert mode (after cursor) |
| `I` | Insert at beginning of line |
| `A` | Insert at end of line |
| `v` | Visual mode (character) |
| `V` | Visual mode (line) |
| `Ctrl+v` | Visual block mode |
| `Esc` / `Ctrl+[` | Return to Normal mode |

### Saving & Quitting
| Command | Action |
|---------|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` / `:x` / `ZZ` | Save and quit |
| `:q!` / `ZQ` | Quit without saving |
| `:wa` | Save all buffers |
| `:qa` | Quit all |

### Basic Movement
| Key | Action |
|-----|--------|
| `h/j/k/l` | Left/Down/Up/Right |
| `w` / `b` | Next/Previous word |
| `0` / `$` | Start/End of line |
| `gg` / `G` | Start/End of file |
| `{` / `}` | Previous/Next paragraph |
| `Ctrl+d` / `Ctrl+u` | Scroll half page down/up |
| `Ctrl+f` / `Ctrl+b` | Scroll full page down/up |

### Counted Motions (with Relative Line Numbers)
**Your config shows relative line numbers - use them for fast navigation!**

| Example | Action |
|---------|--------|
| `10j` | Jump 10 lines down |
| `5k` | Jump 5 lines up |
| `3w` | Jump 3 words forward |
| `2}` | Jump 2 paragraphs down |
| `15G` | Jump to line 15 |

**Pro tip:** Look at the relative number, type that number + motion. Example: see `7` in gutter? Type `7j` to jump there!

### Editing
| Key | Action |
|-----|--------|
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Yank (copy) line **→ copies to system clipboard!** |
| `yw` | Yank word **→ copies to system clipboard!** |
| `p` / `P` | Paste after/before **→ works with system clipboard!** |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `>` / `<` | Indent/Unindent (visual mode) |
| `.` | Repeat last command |

**System Clipboard Integration:**
- All yank/delete operations automatically use system clipboard
- Copy in Neovim with `yy`, paste in any app with `Cmd+v`
- Copy in any app with `Cmd+c`, paste in Neovim with `p`

**Persistent Undo:**
- Your undo history is saved even after closing files!
- Close a file, reopen days later, `u` still works

### Search & Replace
| Command | Action |
|---------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next/Previous match |
| `*` / `#` | Search word under cursor |
| `:noh` / `:nohlsearch` | Clear search highlighting |
| `:s/old/new/g` | Replace in line |
| `:%s/old/new/g` | Replace in file |
| `:%s/old/new/gc` | Replace with confirmation |

**Smart Search:**
- Searching `/foo` finds "foo", "Foo", "FOO" (case-insensitive)
- Searching `/Foo` finds only "Foo" (case-sensitive when you use uppercase)
- Search results are highlighted automatically
- Use `:noh` to clear highlights when done

---

## 🔧 LSP (Language Server Protocol)

**Works with: Python, Rust, Lua**

| Keybinding | Action | Description |
|------------|--------|-------------|
| `gd` | Go to Definition | Jump to where symbol is defined |
| `gr` | Go to References | Show all references |
| `K` | Hover Documentation | Show type info / function docs |
| `<leader>rn` | Rename | Rename symbol across project |
| `<leader>ca` | Code Action | Show available fixes/actions |
| `<leader>f` | Format | Format current buffer |

### Diagnostic Navigation & Viewing
| Keybinding | Action |
|------------|--------|
| `]d` | Go to next diagnostic (E/W/H/I) |
| `[d` | Go to previous diagnostic |
| `gl` | **Show diagnostic message** (floating window) |

### Scrolling in Floating Windows
**For long documentation or diagnostic messages:**
1. Press `K` or `gl` to open floating window
2. Press `Ctrl+w w` to enter the floating window
3. Scroll normally: `j/k`, `Ctrl+d/u`, `Ctrl+f/b`, `gg/G`
4. Press `q` or `Esc` to close and return to code

**Understanding Diagnostics (those letters in the margin):**
- **E** (red) = Error - Code won't compile/run
- **W** (yellow/orange) = Warning - Potential issue
- **I** (blue) = Information - Suggestions
- **H** (gray) = Hint - Minor suggestions (unused vars, simplifications)

**How to work with diagnostics:**
1. See `E` or `H` in margin? Press `]d` to jump to it
2. Press `gl` to see the full error message in a floating window
3. Press `<leader>ca` to see available fixes
4. Or press `<leader>xx` to see all diagnostics in Trouble panel

### LSP Commands
```vim
:LspInfo               # Show LSP status
:LspRestart            # Restart LSP server
:Mason                 # Manage LSP servers
```

---

## 🔍 Telescope (Fuzzy Finder)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ff` | Find Files | Search for files by name |
| `<leader>fg` | Live Grep | Search in file contents |
| `<leader>fb` | Buffers | List open buffers |
| `<leader>fh` | Help Tags | Search help documentation |

### Within Telescope
| Key | Action |
|-----|--------|
| `Ctrl+j` / `Ctrl+k` | Move down/up |
| `Ctrl+n` / `Ctrl+p` | Next/Previous |
| `Enter` | Select |
| `Esc` | Close |
| `Ctrl+c` | Cancel |

---

## 📁 Neo-tree (File Explorer)

| Keybinding | Action |
|------------|--------|
| `<leader>e` | Toggle file tree |

### Within Neo-tree
| Key | Action |
|-----|--------|
| `Space` | Toggle node (expand/collapse) |
| `Enter` | Open file |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `t` | Open in new tab |
| `a` | Add file/directory |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy to clipboard |
| `x` | Cut to clipboard |
| `p` | Paste from clipboard |
| `R` | Refresh |
| `C` | Close node |
| `?` | Show help |

---

## ⚡ Leap (Fast Navigation)

Jump to any visible location with 2-3 keystrokes!

| Keybinding | Action |
|------------|--------|
| `s{char}{char}` | Leap forward |
| `S{char}{char}` | Leap backward |
| `gs{char}{char}` | Leap to other windows |

**Example:** Type `sth` to jump to the next occurrence of "th"

---

## 💬 Completion (nvim-cmp)

| Keybinding | Action |
|------------|--------|
| `Ctrl+Space` | Trigger completion |
| `Ctrl+n` / `Ctrl+p` | Next/Previous item |
| `Enter` | Confirm selection |
| `Ctrl+e` | Abort completion |

---

## 🎨 Git (gitsigns)

### Navigation
| Keybinding | Action |
|------------|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |

### Hunk Operations
| Keybinding | Action |
|------------|--------|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage entire buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hR` | Reset entire buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |

---

## 🧪 Testing (Neotest)

**Visual test explorer like VSCode/IntelliJ**

| Keybinding | Action |
|------------|--------|
| `<leader>tt` | Run nearest test (test under cursor) |
| `<leader>tf` | Run all tests in current file |
| `<leader>ts` | Toggle test summary (sidebar explorer) |
| `<leader>to` | Show test output (floating window) |
| `<leader>tO` | Toggle output panel (bottom panel) |
| `<leader>tl` | Run last test again |
| `<leader>tS` | Stop running test |

**Test status icons in sign column:**
- ✓ (green) = Test passed
- ✗ (red) = Test failed
- ⟳ (yellow) = Test running
- ⊘ (gray) = Test skipped

**Workflow:**
1. Open a Rust file with tests (`01.rs`)
2. Press `<leader>ts` to open test explorer sidebar
3. Press `<leader>tt` to run test under cursor
4. See results inline (✓/✗ in sign column)
5. Press `<leader>to` to see detailed output
6. Navigate to next/previous test, repeat

---

## 🐛 Diagnostics (Trouble)

| Keybinding | Action |
|------------|--------|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xX` | Buffer diagnostics only |
| `<leader>cs` | Symbols list |
| `<leader>xQ` | Quickfix list |
| `<leader>xL` | Location list |

---

## 🪟 Window & Split Management

### Creating Splits
| Command | Action |
|---------|--------|
| `:sp` / `:split` | Horizontal split |
| `:vsp` / `:vsplit` | Vertical split |
| `Ctrl+w s` | Horizontal split |
| `Ctrl+w v` | Vertical split |

### Navigation (Vim + Tmux Integrated)
| Keybinding | Action |
|------------|--------|
| `Ctrl+h` | Move left (works with tmux!) |
| `Ctrl+j` | Move down (works with tmux!) |
| `Ctrl+k` | Move up (works with tmux!) |
| `Ctrl+l` | Move right (works with tmux!) |

### Resizing
| Keybinding | Action |
|------------|--------|
| `Ctrl+w >` / `<` | Increase/decrease width |
| `Ctrl+w +` / `-` | Increase/decrease height |
| `Ctrl+w =` | Equal size |
| `Ctrl+w _` | Maximize height |
| `Ctrl+w \|` | Maximize width |

### Closing
| Keybinding | Action |
|------------|--------|
| `Ctrl+w q` / `:q` | Close current window |
| `:only` | Close all except current |

---

## 📑 Buffers & Tabs

### Buffers
| Command | Action |
|---------|--------|
| `:e file` | Edit/Open file |
| `:bn` / `:bnext` | Next buffer |
| `:bp` / `:bprev` | Previous buffer |
| `:bd` / `:bdelete` | Delete buffer |
| `:ls` / `:buffers` | List buffers |
| `<leader>fb` | Fuzzy find buffers (Telescope) |

### Tabs
| Command | Action |
|---------|--------|
| `:tabnew` | New tab |
| `:tabn` / `gt` | Next tab |
| `:tabp` / `gT` | Previous tab |
| `:tabc` | Close tab |

---

## ⚙️ Configuration Management

### Reloading Config
```vim
:source $MYVIMRC       # Reload init.lua
:Lazy reload           # Reload plugins
```

### Plugin Management
```vim
:Lazy                  # Open Lazy UI
:Lazy sync             # Install/update plugins
:Lazy clean            # Remove unused plugins
:Lazy update           # Update all plugins
:Lazy check            # Check for updates
```

### Mason (LSP/Formatters)
```vim
:Mason                 # Open Mason UI
:MasonInstall <name>   # Install package
:MasonUninstall <name> # Uninstall package
:MasonUpdate           # Update all packages
```

---

## 🎯 Common Workflows

### Opening a Project
```bash
cd ~/myproject
nvim .
```
Then:
1. `<leader>e` - Open file tree
2. `<leader>ff` - Find files
3. `<leader>fg` - Search in project

### Editing Python/Rust Code
1. Open file: `nvim main.py`
2. Wait for LSP to attach (check bottom right)
3. `gd` - Jump to definition
4. `K` - Read documentation
5. `<leader>ca` - See code actions
6. `<leader>f` - Format before saving
7. `:w` - Save

### Git Workflow
1. `<leader>hp` - Preview changes
2. `<leader>hs` - Stage hunks you want
3. Exit Neovim and commit from terminal
4. Or use `<leader>hb` to see blame

### Running Tests (Rust)
1. Open test file: `nvim src/bin/01.rs`
2. `<leader>ts` - Open test explorer sidebar
3. `<leader>tt` - Run test under cursor
4. See ✓/✗ icons in sign column
5. `<leader>to` - View detailed test output
6. Fix code, press `<leader>tl` to rerun last test

### Navigating Large Files
1. `<leader>cs` - Open symbols list
2. `s{char}{char}` - Leap to specific location
3. `/search` - Search for text
4. `gg` / `G` - Jump to top/bottom

### Debugging Errors
1. `:LspInfo` - Check LSP status
2. `<leader>xx` - Open diagnostics
3. `]c` / `[c` - Navigate errors
4. `<leader>ca` - View code actions
5. `:checkhealth` - Check Neovim health

---

## 🎓 Tips & Tricks

1. **Leader key is space** - All `<leader>` commands start with spacebar
2. **Which-key helps** - Press `<leader>` and wait to see available commands
3. **Use relative line numbers** - Look at gutter, type number + motion (e.g., `7j`)
4. **System clipboard is enabled** - `yy` to copy, then `Cmd+v` in any app!
5. **Scroll long floating windows** - Press `Ctrl+w w` to enter any floating window, then scroll with `j/k`
6. **Practice leap** - `s` is your best friend for fast navigation
7. **Use Telescope** - Faster than file tree for known files (`<leader>ff`)
8. **Learn dot command** - `.` repeats last change (super powerful)
9. **Visual block mode** - `Ctrl+v` for column editing
10. **Marks** - `ma` to set mark, `'a` to jump back
11. **Macros** - `qa` to record macro in register a, `@a` to replay
12. **Persistent undo** - Your undo history survives file closes!
13. **Smart search** - `/foo` is case-insensitive, `/Foo` is case-sensitive
14. **Clear search highlights** - Use `:noh` after searching
15. **Mouse works in tmux** - Click to position cursor (but keyboard is faster!)
16. **Splits open smart** - Vertical splits go right, horizontal go below

---

## 📚 Resources

- `:help <topic>` - Built-in help (e.g., `:help telescope`)
- `:Tutor` - Interactive Vim tutorial
- `:checkhealth` - Diagnose issues
- CLAUDE.md in `~/.config/nvim/` - Configuration documentation

---

## 🔑 Quick Reference Card

**Leader Key:**
- `<leader>` = **Spacebar** (press Space and wait to see which-key popup!)

**Most Used:**
- `<leader>ff` - Find files
- `<leader>e` - File tree
- `<leader>ts` - Test explorer sidebar
- `<leader>tt` - Run test under cursor
- `s{char}{char}` - Leap navigation
- `gd` - Go to definition
- `gl` - Show error/diagnostic message
- `K` - Show hover docs/type info
- `Ctrl+w w` - Enter floating window (to scroll long docs)
- `<leader>ca` - Code actions (fixes!)
- `<leader>f` - Format
- `]d` / `[d` - Next/Previous diagnostic
- `Ctrl+h/j/k/l` - Navigate splits/tmux
- `yy` - Copy line (to system clipboard!)
- `{number}j/k` - Jump using relative line numbers
- `:noh` - Clear search highlights

**Enhanced Features:**
- System clipboard auto-enabled (copy/paste anywhere!)
- Relative line numbers (see gutter for jump distances)
- Persistent undo (survives file closes)
- Smart case-sensitive search
- Indent guides with scope highlighting

**Remember:** When stuck, press `<leader>` (Space) and wait for which-key to show options!
