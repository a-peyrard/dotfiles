#!/usr/bin/env bash
# APT Package Manager Implementation (Debian/Ubuntu)
# Contract: update, upgrade, install, is_installed, cleanup

# Package name mappings: requested_name → apt_name
# Use "-" to skip package on this platform
# Only non-identity mappings are listed; unmapped packages use their requested name
declare -A PKG_MAP=(
  # GNU utilities (already present natively on Linux, skip)
  ["coreutils"]="-"
  ["findutils"]="-"
  ["gnu-sed"]="-"
  ["grep"]="-"
  ["bash"]="-"

  # Different package names on Debian/Ubuntu
  ["watch"]="procps"
  ["delta"]="git-delta"

  # macOS-only packages (skip on Linux)
  ["docker"]="-"
  ["nmap"]="-"
  ["socat"]="-"
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
  sudo apt-get update
}

# Upgrade all packages
pkg_upgrade() {
  sudo apt-get upgrade -y
}

# Check if package is installed
pkg_is_installed() {
  local requested="$1"
  local pkg_name=$(pkg_get_name "$requested")
  dpkg -l "$pkg_name" 2>/dev/null | grep -q "^ii"
}

# Install a package
pkg_install() {
  local requested="$1"
  local dry_run="${2:-0}"

  if pkg_should_skip "$requested"; then
    echo " ⏩  skip ${bold}${requested}${normal}, not needed on Linux"
    return 0
  fi

  local pkg_name=$(pkg_get_name "$requested")

  if pkg_is_installed "$requested"; then
    echo " ⏩  skip ${bold}${requested}${normal}, already installed"
    return 0
  fi

  if [[ ${dry_run} == 1 ]]; then
    echo "(DRY RUN) apt-get install ${pkg_name}"
    return 0
  fi

  echo "Installing ${requested} (as ${pkg_name})..."
  sudo apt-get install -y "$pkg_name"
}

# Cleanup
pkg_cleanup() {
  sudo apt-get autoremove -y
  sudo apt-get clean
}

# Stubs for macOS-specific functions (no-op on Linux)
pkg_install_cask() {
  echo " ⏩  skip cask ${1}, not on macOS"
  return 0
}

pkg_add_tap() {
  return 0  # Silently skip
}
