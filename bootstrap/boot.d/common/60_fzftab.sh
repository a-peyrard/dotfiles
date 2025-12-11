#!/usr/bin/env bash
# Install fzf-tab standalone (no longer needs OMZ)
fzf_tab_path="$HOME/.zsh/plugins/fzf-tab"

if [ ! -d "$fzf_tab_path" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$fzf_tab_path"
fi