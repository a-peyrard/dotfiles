# Snapshot Deployment Guide

Quick guide for deploying dotfiles to remote servers using the snapshot method.

## What is Snapshot Deployment?

Creates a portable, self-contained snapshot of your working dotfiles environment. Perfect for remote servers without git access.

**Includes:**
- All config files (symlinks resolved)
- Runtime plugins (tmux, zsh, vim)
- Standalone package installer
- No git repository needed

## Creating a Snapshot

```bash
cd ~/config/dotfiles
dotfiles-package /tmp/dotfiles.tar.gz
```

## Deploying to a Server

### Method 1: Direct Deployment (Fresh Systems)

For fresh systems where you want to install as-is:

```bash
# 1. Transfer
scp /tmp/dotfiles.tar.gz user@server:/tmp/

# 2. SSH to server
ssh user@server

# 3. Check what would be overwritten (optional)
cd /tmp
tar -xzf dotfiles.tar.gz dotfiles-snapshot/check-conflicts.sh --strip-components=1
bash check-conflicts.sh dotfiles.tar.gz
rm check-conflicts.sh

# 4. Extract to home
cd $HOME
tar -xzf /tmp/dotfiles.tar.gz --strip-components=1

# 5. Test what would be installed (optional)
bash install-packages.sh --dry-run

# 6. Install packages and reload
bash install-packages.sh
rm install-packages.sh README.md check-conflicts.sh
rm -rf util/
exec zsh -l
```

**One-Liner:**
```bash
scp /tmp/dotfiles.tar.gz user@server:/tmp/ && \
ssh -t user@server 'cd $HOME && tar -xzf /tmp/dotfiles.tar.gz --strip-components=1 && bash install-packages.sh && rm install-packages.sh README.md check-conflicts.sh && rm -rf util && exec zsh -l'
```

### Method 2: Extract, Edit, Then Deploy (Existing Configurations)

For systems with existing configs where you need to customize before installing:

```bash
# 1. Transfer
scp /tmp/dotfiles.tar.gz user@server:/tmp/

# 2. SSH to server
ssh user@server

# 3. Extract to /tmp for editing
cd /tmp
tar -xzf dotfiles.tar.gz --strip-components=1

# 4. Edit files as needed
vim .zshrc       # Add custom lines, modify settings
vim .gitconfig   # Update name/email
vim .env.d/common/30_aliases.env  # Add custom aliases

# 5. Preview what will be installed (optional, -n for dry-run)
rsync -avn --exclude='install-packages.sh' --exclude='README.md' \
  --exclude='check-conflicts.sh' --exclude='util/' ./ ~/

# 6. Install everything (safely merges with existing directories)
rsync -av --exclude='install-packages.sh' --exclude='README.md' \
  --exclude='check-conflicts.sh' --exclude='util/' ./ ~/

# 7. Install packages
bash install-packages.sh

# 8. Clean up temp files
cd ~
rm -rf /tmp/install-packages.sh /tmp/util /tmp/README.md /tmp/check-conflicts.sh

# 9. Reload shell
exec zsh -l
```

**Why rsync?**
- Safely merges directories (e.g., preserves existing `~/.config/htop/` while adding `.config/starship.toml`)
- Doesn't overwrite the entire `.config` directory like `cp -r` would
- Preview changes with `-n` (dry-run) before applying

## What Gets Installed

The `install-packages.sh` script auto-detects your OS (CentOS/Ubuntu/Arch/macOS) and installs:

**Essential packages:**
git, tmux, zsh, vim, tree, autojump, watch, jq, fzf, rsync, htop, delta, git-lfs, glow, highlight, zsh-syntax-highlighting, starship, ack, docker

**Some packages may need manual install** (if not in default repos):

**Starship:**
```bash
curl -sS https://starship.rs/install.sh | sh
```

**Git Delta:**
```bash
# Download from https://github.com/dandavison/delta/releases
curl -LO https://github.com/dandavison/delta/releases/latest/download/git-delta-*-x86_64-unknown-linux-gnu.tar.gz
tar -xzf git-delta-*.tar.gz
sudo mv delta /usr/local/bin/
```

**Glow:**
```bash
# Download from https://github.com/charmbracelet/glow/releases
curl -LO https://github.com/charmbracelet/glow/releases/latest/download/glow_*_Linux_x86_64.tar.gz
tar -xzf glow_*.tar.gz
sudo mv glow /usr/local/bin/
```

## Updating Your Dotfiles

To update dotfiles on a server:

```bash
# 1. Create new snapshot locally
dotfiles-package /tmp/dotfiles.tar.gz

# 2. Deploy update
scp /tmp/dotfiles.tar.gz user@server:/tmp/
ssh user@server 'cd $HOME && tar -xzf /tmp/dotfiles.tar.gz --strip-components=1 && exec zsh -l'
```

## Troubleshooting

**Check what files would be overwritten:**
```bash
bash check-conflicts.sh /tmp/dotfiles.tar.gz
```

**Backup existing dotfiles:**
```bash
mkdir ~/dotfiles-backup
tar -czf ~/dotfiles-backup/backup-$(date +%Y%m%d).tar.gz ~/.zshrc ~/.gitconfig ~/.vimrc ~/.tmux.conf
```

**Packages not found:** Some packages aren't in default repos. Install manually (see above).

**Starship not working:** Install manually and reload: `curl -sS https://starship.rs/install.sh | sh && exec zsh -l`

**Existing dotfiles:** Backup first: `mkdir ~/dotfiles-backup && mv ~/.zshrc ~/.gitconfig ~/.vimrc ~/dotfiles-backup/`

## Full Documentation

See `.claude/SNAPSHOT_DEPLOYMENT.md` for complete details, troubleshooting, and customization options.
