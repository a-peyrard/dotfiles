#!/bin/bash
# Install zsh-vi-mode plugin

ZVM_DIR="$HOME/.zsh/plugins/zsh-vi-mode"

if [[ "$1" == "--dry-run" ]]; then
    echo "[DRY RUN] Would clone zsh-vi-mode to $ZVM_DIR"
    exit 0
fi

if [[ -d "$ZVM_DIR" ]]; then
    echo "zsh-vi-mode already installed at $ZVM_DIR"
    exit 0
fi

mkdir -p "$(dirname "$ZVM_DIR")"
git clone https://github.com/jeffreytse/zsh-vi-mode.git "$ZVM_DIR"
echo "zsh-vi-mode installed to $ZVM_DIR"
