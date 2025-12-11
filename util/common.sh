#!/usr/bin/env bash
# Common utilities and formatting variables for dotfiles scripts
# Source this file in scripts that need formatting or shared utility functions

# Terminal formatting
bold=$(tput bold 2>/dev/null || echo "")
normal=$(tput sgr0 2>/dev/null || echo "")

# Future: Add colors, common utility functions, etc.
# red=$(tput setaf 1 2>/dev/null || echo "")
# green=$(tput setaf 2 2>/dev/null || echo "")
# yellow=$(tput setaf 3 2>/dev/null || echo "")
