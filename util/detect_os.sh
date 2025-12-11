#!/usr/bin/env bash
# OS Detection Utility
# Detects operating system, distribution, and package manager
# This file should be sourced by other scripts to get OS information

# Detect OS type (macOS or Linux)
detect_os_type() {
  case "$(uname -s)" in
    Darwin*)  echo "macos" ;;
    Linux*)   echo "linux" ;;
    *)        echo "unknown" ;;
  esac
}

# Detect Linux distribution
detect_linux_distro() {
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "$ID" in
      centos|rhel|fedora)  echo "centos" ;;  # Group RHEL-based together
      ubuntu|debian)       echo "ubuntu" ;;  # Group Debian-based together
      arch|manjaro)        echo "arch" ;;
      *)                   echo "" ;;  # Unknown = empty string
    esac
  else
    echo ""  # No os-release = empty string
  fi
}

# Detect package manager
detect_package_manager() {
  local os_type="$1"

  if [ "$os_type" = "macos" ]; then
    echo "brew"
  elif [ "$os_type" = "linux" ]; then
    # Check for package managers in order of preference
    # Note: We return "dnf" for both dnf and yum (dnf.sh handles both)
    if command -v dnf &> /dev/null; then
      echo "dnf"
    elif command -v yum &> /dev/null; then
      echo "dnf"  # Use dnf.sh even for yum systems
    elif command -v apt-get &> /dev/null; then
      echo "apt"
    elif command -v pacman &> /dev/null; then
      echo "pacman"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

# Main detection logic
export OS_TYPE=$(detect_os_type)

if [ "$OS_TYPE" = "linux" ]; then
  export DISTRO=$(detect_linux_distro)
else
  export DISTRO=""  # macOS has no distro
fi

export PKG_MANAGER=$(detect_package_manager "$OS_TYPE")

# Set HOMEBREW_PREFIX for macOS
if [ "$OS_TYPE" = "macos" ]; then
  if [ -d "/opt/homebrew" ]; then
    # Apple Silicon
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [ -d "/usr/local/Homebrew" ]; then
    # Intel Mac
    export HOMEBREW_PREFIX="/usr/local"
  else
    # Try to detect from brew command
    if command -v brew &> /dev/null; then
      export HOMEBREW_PREFIX="$(brew --prefix)"
    else
      export HOMEBREW_PREFIX=""
    fi
  fi
else
  export HOMEBREW_PREFIX=""
fi

# Optional: Print detected values (can be commented out)
if [ "${VERBOSE_DETECT:-0}" = "1" ]; then
  echo "OS Detection:"
  echo "  OS_TYPE: $OS_TYPE"
  echo "  DISTRO: $DISTRO"
  echo "  PKG_MANAGER: $PKG_MANAGER"
  echo "  HOMEBREW_PREFIX: $HOMEBREW_PREFIX"
fi

# Source the appropriate package manager implementation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/package_managers/${PKG_MANAGER}.sh" ]; then
  # shellcheck disable=SC1090
  source "$SCRIPT_DIR/package_managers/${PKG_MANAGER}.sh"
else
  echo "Warning: No package manager implementation found for: $PKG_MANAGER"
fi

