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
| `Esc` / `Ctrl+[` / `jk` | Return to Normal mode |

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

### Incremental Selection (Wildfire)
**Expand/shrink selection intelligently based on syntax (like IntelliJ's Ctrl+W)**

| Key | Action |
|-----|--------|
| `gn` | Start selection (select current word/node) |
| `<CR>` (Enter) | **Expand** selection (word → line → block → function) |
| `<BS>` (Backspace) | **Shrink** selection (reverse) |

**Example workflow:**
1. Put cursor on `device` inside `if device == "out" {`
2. Press `gn` - selects `device`
3. Press `<CR>` - expands to `device == "out"`
4. Press `<CR>` - expands to entire `if` condition
5. Press `<CR>` - expands to entire `if` block
6. Press `<BS>` - shrinks back one level

**Pro tip:** Much faster than manually selecting with `v` + motion!

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

**Works with: Python, Rust, Go, Lua**

| Keybinding | Action | Description |
|------------|--------|-------------|
| `gd` | Go to Definition | Jump to where symbol is defined |
| `gr` | Go to References | Show all references |
| `K` | Hover Documentation | Show type info / function docs |
| `gK` | Signature Help | Show function signature & parameters (works anywhere in function call) |
| `<leader>rn` | Rename | Rename symbol across project |
| `<leader>ca` | Code Action | Show available fixes/actions |
| `<leader>cf` | Format | Format current buffer |

**When to use K vs gK:**
- `K` on a function/variable → shows full documentation
- `gK` anywhere inside a function call → shows signature with parameter names & types
- Example: In `myFunc(arg1, arg2)`, cursor on `arg1` → press `gK` to see what parameters `myFunc` expects

### Call Hierarchy
| Keybinding | Action |
|------------|--------|
| `<leader>ci` | Incoming calls (who calls this function) |
| `<leader>co` | Outgoing calls (what this function calls) |

### Diagnostic Navigation & Viewing
| Keybinding | Action |
|------------|--------|
| `]d` | Go to next diagnostic (E/W/H/I) |
| `[d` | Go to previous diagnostic |
| `gl` | **Show diagnostic message** (floating window) |

### Scrolling in Floating Windows
**For long documentation or diagnostic messages:**
1. Press `K`, `gK`, or `gl` to open floating window
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

## 🔍 Picker (snacks.nvim)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ff` | Find Files | Search for files by name |
| `<leader>fg` | Live Grep | Search in file contents |
| `<leader>fb` | Buffers | List open buffers |
| `<leader>fh` | Help Tags | Search help documentation |
| `<leader>fk` | Keymaps | Search all keybindings |
| `<leader>fc` | Commands | Search all commands |
| `<leader>fr` | Recent Files | Recently opened files |
| `<leader>fd` | Diagnostics | Search diagnostics |
| `<leader>fs` | LSP Symbols (buffer) | Symbols in current file |
| `<leader>fS` | LSP Symbols (project) | Search symbols across project |
| `<leader>fi` | Icons/Emoji | Pick icons and emoji |
| `<leader>ft` | Themes | Pick colorscheme with live preview |

### Git Pickers
| Keybinding | Action |
|------------|--------|
| `<leader>gc` | Git commits |
| `<leader>gb` | Git branches |
| `<leader>gs` | Git status |

### Within Picker
| Key | Action |
|-----|--------|
| `Ctrl+j` / `Ctrl+k` | Move down/up |
| `Enter` | Select |
| `Esc` | Close |

---

## 📁 Explorer (snacks.nvim)

| Keybinding | Action |
|------------|--------|
| `<leader>e` | Toggle file explorer |

---

## ⚡ Flash (Fast Navigation)

Jump to any visible location with labels!

| Keybinding | Action |
|------------|--------|
| `s{char}{char}` | Flash jump (type chars, then label) |
| `S` | Flash Treesitter (select syntax node) |
| `f{char}` / `F{char}` | Enhanced f/F with jump labels |
| `t{char}` / `T{char}` | Enhanced t/T with jump labels |
| `<C-s>` | Toggle Flash during `/` search |

**Flash jump example:** Type `sth` → labels appear on all "th" matches → press label to jump

**Treesitter example:** Press `S` → syntax nodes are labeled → press label to select entire node (function, block, etc.)

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

**For Git repositories**

### Navigation
| Keybinding | Action |
|------------|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |

### Hunk Operations
| Keybinding | Action |
|------------|--------|
| `<leader>hs` | Stage hunk (n) / Stage selected lines (v) |
| `<leader>hr` | Reset hunk (n) / Reset selected lines (v) |
| `<leader>hS` | Stage entire buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hR` | Reset entire buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |
| `<leader>hL` | List all hunks (quickfix) |

**Visual mode workflow:**
1. Enter visual mode with `V` (line) or `v` (character)
2. Select the lines you want to stage/reset
3. Press `<leader>hr` to revert selected lines to HEAD
4. Or press `<leader>hs` to stage only selected lines

---

## 🔶 Mercurial/Sapling (vim-signify)

**For Mercurial and Sapling repositories**

| Keybinding | Action |
|------------|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>hd` | Diff this |
| `<leader>hp` | Preview hunk |
| `<leader>hu` | Undo hunk |
| `<leader>hR` | Revert entire file |
| `<leader>hL` | List all hunks (quickfix) |

**Note:** Same gutter signs as Git (+/-/~). Auto-detects VCS type.

---

## 🔀 Conflict Resolution & Diff (diffview.nvim)

**Works with Git and Mercurial - 3-way diff with conflict resolution**

### Opening Diffview
| Keybinding | Action |
|------------|--------|
| `<leader>gd` | Open Diffview (show conflicts/changes) |
| `<leader>gD` | Close Diffview |
| `<leader>gh` | File history (current file) |
| `<leader>gH` | Branch history |

### Navigation (inside Diffview)
| Keybinding | Action |
|------------|--------|
| `]x` | Jump to next conflict |
| `[x` | Jump to previous conflict |
| `j` / `k` | Navigate file panel |
| `Enter` | Open entry |
| `q` | Close Diffview |

### Resolution (cursor on conflict)
| Keybinding | Action |
|------------|--------|
| `<leader>co` | Choose **o**urs (your local changes) |
| `<leader>ct` | Choose **t**heirs (incoming changes) |
| `<leader>cb` | Choose **b**ase (common ancestor) |
| `<leader>ca` | Choose **a**ll (keep all versions) |
| `dx` | Delete conflict region |

**Workflow:**
1. During merge/rebase, run `<leader>gd` to open Diffview
2. Conflicted files appear in a dedicated section
3. Select a file to open 3-way diff view
4. Press `]x` to jump to first conflict
5. Use `<leader>co`, `<leader>ct`, `<leader>cb`, or `<leader>ca` to resolve
6. Press `]x` for next conflict
7. Press `q` to close when done
8. Save with `:w` and continue merge/rebase

---

## 🧪 Testing (Neotest)

**Visual test explorer like VSCode/IntelliJ**

| Keybinding | Action |
|------------|--------|
| `<leader>tt` | Run nearest test (test under cursor) |
| `<leader>td` | **Debug nearest test** (opens DAP debugger) |
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

## 🐛 Debugging (DAP - Debug Adapter Protocol)

**Interactive debugger for Python, Rust, and Go with breakpoints, stepping, and variable inspection**

### Starting & Controlling Debugger
| Keybinding | Action |
|------------|--------|
| `F5` | Start debugging / Continue |
| `F10` | Step over (execute current line) |
| `F11` | Step into (enter function) |
| `F12` | Step out (exit function) |
| `<leader>dt` | Terminate debugging session |
| `<leader>dl` | Run last debug configuration |

### Breakpoints
| Keybinding | Action |
|------------|--------|
| `<leader>db` | Toggle breakpoint at current line |
| `<leader>dB` | Set conditional breakpoint (with expression) |
| `<leader>dL` | List all breakpoints (opens in location list) |
| `<leader>dC` | Clear all breakpoints |

### Inspecting Variables
| Keybinding | Action |
|------------|--------|
| `<leader>dh` | Hover to see variable value (during debug) |
| `<leader>dp` | Preview variable value |
| `<leader>dr` | Open REPL (evaluate expressions) |
| `<leader>du` | Toggle debug UI (scopes/watches/stacks/console) |

### Breakpoint & Debugging Icons
**In the sign column (left margin):**
- ● (red) = Breakpoint set
- ◆ (red) = Conditional breakpoint
- → (yellow) = Execution stopped here
- ○ (gray) = Breakpoint rejected/disabled

**In the code (virtual text):**
- Variable values appear inline when debugging
- Highlighted when values change

### Debug UI Layout
**When you press `F5` or `<leader>du`, the UI auto-opens:**
- **Left sidebar:** Scopes (local/global vars), Breakpoints, Call stack, Watches
- **Bottom panel:** REPL (interactive console), Console output

**Workflow:**
1. Open Python or Rust file
2. Press `<leader>db` to set breakpoint(s)
3. Press `F5` to start debugging
4. Debug UI opens automatically
5. Use `F10` to step through code
6. Hover over variables or check left sidebar for values
7. Press `F5` to continue to next breakpoint
8. Press `<leader>dt` to stop debugging

### Debug Configurations

**Python:**
- Automatically detects virtual environment (`$VIRTUAL_ENV`)
- Falls back to system Python if no venv active
- "Launch file" - runs current file
- "Launch file with arguments" - prompts for CLI args

**Rust:**
- Debugs compiled binaries from `target/debug/`
- Prompts for executable path when starting
- Make sure to build with debug symbols: `cargo build`

**Go:**
- Debugs Go programs using Delve debugger
- "Debug" - runs current file
- "Debug test" - runs tests in current file
- "Debug package" - debugs entire package
- Build automatically includes debug symbols

### Debug Commands
```vim
:DapContinue           # Start/continue debugging (same as F5)
:DapStepOver           # Step over (F10)
:DapStepInto           # Step into (F11)
:DapStepOut            # Step out (F12)
:DapToggleBreakpoint   # Toggle breakpoint (<leader>db)
:DapTerminate          # Stop debugging (<leader>dt)
```

**Installing Debug Adapters:**
The debug adapters (debugpy for Python, codelldb for Rust, delve for Go) are automatically installed via Mason on first launch. If they're missing:
```vim
:Mason                 # Open Mason, search for debugpy, codelldb, or delve
```

---

## 🚨 Diagnostics (Trouble)

| Keybinding | Action |
|------------|--------|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xX` | Buffer diagnostics only |
| `<leader>cs` | Symbols list |
| `<leader>xQ` | Quickfix list |
| `<leader>xL` | Location list |

---

## 💬 Messages & Notifications

### Noice (Cmdline & Messages)
| Keybinding | Action |
|------------|--------|
| `<leader>snl` | Show last message |
| `<leader>sna` | Show all messages |

### Snacks Notifier
| Keybinding | Action |
|------------|--------|
| `<leader>snd` | Dismiss all notifications |
| `<leader>snh` | Notification history |

**Commands:**
- `:Noice` — Open message history
- `:Noice last` — Show last message
- `:Noice errors` — Show errors only

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
| `<leader>fb` | Fuzzy find buffers |

### Tabs
| Command | Action |
|---------|--------|
| `:tabnew` | New tab |
| `:tabn` / `gt` | Next tab |
| `:tabp` / `gT` | Previous tab |
| `:tabc` | Close tab |

---

## ⚙️ Configuration Management

### Autosave (IntelliJ-like)
- Automatically saves when switching apps or buffers
- `<leader>ua` - Toggle autosave on/off

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

### Editing Python/Rust/Go Code
1. Open file: `nvim main.py` (or `main.rs`, `main.go`)
2. Wait for LSP to attach (check bottom right)
3. `gd` - Jump to definition
4. `K` - Read documentation
5. `gK` - See function signature (when inside function calls)
6. `<leader>ca` - See code actions
7. `<leader>cf` - Format before saving
8. `:w` - Save

### Git Workflow
1. `<leader>hp` - Preview changes
2. `<leader>hs` - Stage hunks you want (or visually select lines and stage them)
3. `<leader>hr` - Reset unwanted changes (or visually select lines to revert)
4. Exit Neovim and commit from terminal
5. Or use `<leader>hb` to see blame

### Running Tests (Rust/Go)
1. Open test file: `nvim src/bin/01.rs` or `nvim main_test.go`
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

### Debugging Code Errors (LSP Diagnostics)
1. `:LspInfo` - Check LSP status
2. `<leader>xx` - Open diagnostics
3. `]d` / `[d` - Navigate errors
4. `<leader>ca` - View code actions
5. `:checkhealth` - Check Neovim health

### Debugging with Breakpoints (DAP)
1. Open Python, Rust, or Go file: `nvim main.py` / `main.rs` / `main.go`
2. Set breakpoint: `<leader>db` on the line you want to pause at
3. Start debugging: `F5` (prompts for debug config)
4. Debug UI opens automatically with variables/call stack
5. Step through code: `F10` (over), `F11` (into), `F12` (out)
6. Hover over variables: `<leader>dh` to see values
7. Continue to next breakpoint: `F5`
8. Stop debugging: `<leader>dt`

**Breakpoint Management:**
- Breakpoints **persist across sessions** automatically (saved per project)
- `<leader>dL` - View all breakpoints in a list
- `<leader>dC` - Clear all breakpoints at once
- Conditional breakpoints: `<leader>dB` then enter expression (e.g., `x > 10`)

**Python debugging tip:** Activate your venv first for proper imports!
**Rust debugging tip:** Build with debug symbols: `cargo build` (not `--release`)
**Go debugging tip:** Delve works out of the box, just press `F5` to start!

---

## 🎓 Tips & Tricks

1. **Leader key is space** - All `<leader>` commands start with spacebar
2. **Quick escape from insert mode** - Type `jk` to exit insert mode (faster than reaching for Esc)
3. **Which-key helps** - Press `<leader>` and wait to see available commands
4. **Use relative line numbers** - Look at gutter, type number + motion (e.g., `7j`)
5. **System clipboard is enabled** - `yy` to copy, then `Cmd+v` in any app!
6. **Scroll long floating windows** - Press `Ctrl+w w` to enter any floating window, then scroll with `j/k`
7. **Practice flash** - `s` is your best friend for fast navigation
8. **Use picker** - Faster than file tree for known files (`<leader>ff`)
9. **Learn dot command** - `.` repeats last change (super powerful)
10. **Visual block mode** - `Ctrl+v` for column editing
11. **Marks** - `ma` to set mark, `'a` to jump back
12. **Macros** - `qa` to record macro in register a, `@a` to replay
13. **Persistent undo** - Your undo history survives file closes!
14. **Smart search** - `/foo` is case-insensitive, `/Foo` is case-sensitive
15. **Clear search highlights** - Use `:noh` after searching
16. **Mouse works in tmux** - Click to position cursor (but keyboard is faster!)
17. **Splits open smart** - Vertical splits go right, horizontal go below

---

## 📚 Resources

- `:help <topic>` - Built-in help (e.g., `:help snacks`)
- `:Tutor` - Interactive Vim tutorial
- `:checkhealth` - Diagnose issues
- CLAUDE.md in `~/.config/nvim/` - Configuration documentation

---

## 🔑 Quick Reference Card

**Leader Key:**
- `<leader>` = **Spacebar** (press Space and wait to see which-key popup!)

**Most Used:**
- `<leader>fk` - Search keymaps (find any keybinding)
- `<leader>fc` - Search commands
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>e` - File explorer
- `<leader>ts` - Test explorer sidebar
- `<leader>tt` - Run test under cursor
- `s{char}{char}` - Flash navigation
- `gd` - Go to definition
- `K` - Show hover docs/type info
- `gK` - Show function signature (works in params!)
- `gl` - Show error/diagnostic message
- `Ctrl+w w` - Enter floating window (to scroll long docs)
- `<leader>ca` - Code actions (fixes!)
- `<leader>cf` - Format
- `]d` / `[d` - Next/Previous diagnostic
- `Ctrl+h/j/k/l` - Navigate splits/tmux
- `yy` - Copy line (to system clipboard!)
- `{number}j/k` - Jump using relative line numbers
- `:noh` - Clear search highlights

**Debugging:**
- `<leader>db` - Toggle breakpoint
- `<leader>dB` - Conditional breakpoint
- `<leader>dL` - List all breakpoints
- `<leader>dC` - Clear all breakpoints
- `F5` - Start/Continue debugging
- `F10` - Step over
- `F11` - Step into
- `F12` - Step out
- `<leader>dh` - Hover variable (debug)
- `<leader>du` - Toggle debug UI
- `<leader>dt` - Terminate debug session

**Enhanced Features:**
- System clipboard auto-enabled (copy/paste anywhere!)
- Relative line numbers (see gutter for jump distances)
- Persistent undo (survives file closes)
- Persistent breakpoints (saved per project across sessions)
- Smart case-sensitive search
- Indent guides with scope highlighting

**Remember:** When stuck, press `<leader>` (Space) and wait for which-key to show options! Or use `<leader>fk` to search keymaps.
