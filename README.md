# Dotfiles

Cross-platform dotfiles for macOS and Linux (CentOS/Ubuntu/Arch).

## Quick Start

### Local Installation (Development Machines)

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Remote Server Deployment (Recommended)

For deploying to remote servers without git:

```bash
# Create snapshot
dotfiles-package /tmp/dotfiles.tar.gz

# Deploy to server
scp /tmp/dotfiles.tar.gz user@server:/tmp/
ssh user@server

# Check conflicts (optional)
cd /tmp
tar -xzf dotfiles.tar.gz dotfiles-snapshot/check-conflicts.sh --strip-components=1
bash check-conflicts.sh /tmp/dotfiles.tar.gz

# Extract and install
cd $HOME
tar -xzf /tmp/dotfiles.tar.gz --strip-components=1
bash install-packages.sh --dry-run  # Preview
bash install-packages.sh            # Install
exec zsh -l
```

**📖 See [SNAPSHOT.md](SNAPSHOT.md) for complete snapshot deployment guide**

## Features

- **Cross-platform:** Works on macOS and Linux (CentOS, Ubuntu, Arch)
- **Minimal install:** Only essential packages, no dev tools by default
- **Modular configuration:** Environment files organized by platform
- **Modern shell:** Zsh with Starship prompt, syntax highlighting, fzf-tab
- **Git integration:** Delta pager, extensive aliases
- **Tmux:** Plugin manager with resurrect/continuum
- **Window management:** Yabai + skhd (macOS only)

## Documentation

- **[SNAPSHOT.md](SNAPSHOT.md)** - Remote server deployment guide

## What's Included

**Shell:**
- Zsh with Starship prompt
- Syntax highlighting
- FZF tab completion
- Autojump navigation

**Git:**
- Delta pager (side-by-side diffs)
- Extensive aliases
- Auto HTTPS→SSH URL conversion

**Editors:**
- Vim with plugins (gruvbox, typescript-vim)
- Tmux with plugin manager

**macOS:**
- Yabai window management
- skhd hotkey daemon
- Custom window reorganization scripts

## Installation Methods

| Method | Best For | Git Required | Includes Plugins |
|--------|----------|--------------|------------------|
| `./install.sh` | Development machines | ✅ Yes | Installs via bootstrap |
| Snapshot | Remote servers | ❌ No | Pre-installed |

## License

MIT
