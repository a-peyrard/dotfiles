#!/usr/bin/env bash
# Homebrew Package Manager Implementation (macOS)
# Contract: update, upgrade, install, is_installed, cleanup, install_cask, add_tap

# Package name mappings: requested_name → homebrew_name
# Use "-" to skip package on this platform
# Only non-identity mappings are listed; unmapped packages use their requested name
declare -A PKG_MAP=(
  # Git tools (different package name)
  ["delta"]="git-delta"
)

# Get package name for this package manager
pkg_get_name() {
  local requested="$1"
  local mapped="${PKG_MAP[$requested]}"

  # If no mapping, use requested name
  [ -z "$mapped" ] && echo "$requested" || echo "$mapped"
}

# Check if package should be skipped
pkg_should_skip() {
  local pkg_name=$(pkg_get_name "$1")
  [ "$pkg_name" = "-" ] && return 0
  return 1
}

# Update package manager
pkg_update() {
  brew update
}

# Upgrade all packages
pkg_upgrade() {
  brew upgrade
  brew upgrade --cask
}

# Check if package is installed
pkg_is_installed() {
  local requested="$1"
  local pkg_name=$(pkg_get_name "$requested")
  brew list "$pkg_name" &>/dev/null
}

# Install a package
pkg_install() {
  local requested="$1"
  local dry_run="${2:-0}"

  if pkg_should_skip "$requested"; then
    echo " ⏩  skip ${bold}${requested}${normal}, not needed on macOS"
    return 0
  fi

  local pkg_name=$(pkg_get_name "$requested")

  if pkg_is_installed "$requested"; then
    echo " ⏩  skip ${bold}${requested}${normal}, already installed"
    return 0
  fi

  if [[ ${dry_run} == 1 ]]; then
    echo "(DRY RUN) brew install ${pkg_name}"
    return 0
  fi

  echo "Installing ${requested} (as ${pkg_name})..."
  brew install "$pkg_name"
}

# Cleanup
pkg_cleanup() {
  brew cleanup
}

# Install cask (macOS-specific)
pkg_install_cask() {
  local cask_name="$1"
  local dry_run="${2:-0}"

  if brew list --cask "$cask_name" &>/dev/null; then
    echo " ⏩  skip cask ${bold}${cask_name}${normal}, already installed"
    return 0
  fi

  if [[ ${dry_run} == 1 ]]; then
    echo "(DRY RUN) brew install --cask ${cask_name}"
    return 0
  fi

  brew install --cask "$cask_name"
}

# Add Homebrew tap (macOS-specific)
pkg_add_tap() {
  local tap_name="$1"
  local dry_run="${2:-0}"

  if [[ ${dry_run} == 1 ]]; then
    echo "(DRY RUN) brew tap ${tap_name}"
    return 0
  fi

  brew tap "$tap_name"
}
