#!/usr/bin/env bash
# Homebrew Package Manager Implementation (macOS)
# Contract: update, upgrade, install, is_installed, cleanup, install_cask, add_tap

# Get package name for this package manager
# Use "-" to skip package on this platform
# Only non-identity mappings are listed; unmapped packages use their requested name
#
# NOTE: macOS ships bash 3.2, which has no associative arrays — hence case
# rather than the PKG_MAP used by apt.sh/dnf.sh.
pkg_get_name() {
  local requested="$1"

  case "$requested" in
    # Git tools (different package name)
    delta) echo "git-delta" ;;
    *)     echo "$requested" ;;
  esac
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

# Cache of installed packages (populated on first check)
_brew_installed_formulae=""
_brew_installed_casks=""

_brew_ensure_cache() {
  if [ -z "$_brew_installed_formulae" ]; then
    _brew_installed_formulae=$(brew list --formula -1)
    _brew_installed_casks=$(brew list --cask -1)
  fi
}

# Check if package is installed
pkg_is_installed() {
  local requested="$1"
  local pkg_name=$(pkg_get_name "$requested")
  _brew_ensure_cache
  echo "$_brew_installed_formulae" | grep -qx "$pkg_name"
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

  _brew_ensure_cache
  if echo "$_brew_installed_casks" | grep -qx "$cask_name"; then
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
