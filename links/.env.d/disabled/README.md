# Disabled Environment Files

This directory contains environment files that are **not** part of the core dotfiles configuration.

## Files in this directory:

- **11_benchmark_ops.env** - Go benchmark formatting alias (project-specific)
- **12_betterworks-dev.env** - Betterworks development environment setup (project-specific)
- **31_nvm.env** - NVM configuration (BROKEN - references deprecated oh-my-zsh)

## Why disabled?

These files are either:
1. **Project-specific**: Configuration for specific work projects (Betterworks)
2. **Broken**: References removed dependencies (oh-my-zsh)
3. **Development tools**: Not needed for core dotfiles functionality

## How to enable:

If you need these configurations:

1. **For project-specific configs**: Consider moving to `~/.zshenv.private` instead of dotfiles
2. **For NVM**: If you install NVM and want it integrated, create a new file in the appropriate subdirectory:
   - `links/.env.d/common/31_nvm.env` for cross-platform NVM support
   - Load NVM directly without oh-my-zsh dependency:
     ```bash
     export NVM_DIR="$HOME/.nvm"
     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
     [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
     ```
