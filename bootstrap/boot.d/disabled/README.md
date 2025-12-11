# Disabled Bootstrap Scripts

This directory contains bootstrap scripts that are **not** part of the minimal dotfiles installation.

## Scripts in this directory:

- **50_deno.sh** - Installs Deno runtime
- **51_nvm.sh** - Installs Node Version Manager (NVM)
- **52_npm.sh** - Installs npm packages (fx-theme-monokai)

## Why disabled?

The minimal dotfiles installation only includes packages directly used by shell/editor/terminal functionality. Development tools like Deno, Node.js, and NVM are not included by default.

## How to enable:

If you want to install these tools, you can:
1. Move the script(s) you want to the appropriate subdirectory:
   - Cross-platform tools → `bootstrap/boot.d/common/`
   - macOS-only tools → `bootstrap/boot.d/macos/`
   - Linux-only tools → `bootstrap/boot.d/linux/`
2. Run `./install.sh` to execute the newly enabled scripts

Alternatively, you can run these scripts manually:
```bash
bash bootstrap/boot.d/disabled/50_deno.sh
bash bootstrap/boot.d/disabled/51_nvm.sh
```
