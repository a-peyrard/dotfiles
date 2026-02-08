# ~/.zshrc - Zsh configuration without Oh My Zsh
# Modern setup using Starship prompt and modular env.d configuration

# =============================================================================
# OS Detection (must be first)
# =============================================================================

# Detect OS type for conditional configuration
if [[ "$(uname -s)" == "Darwin" ]]; then
  export OS_TYPE="macos"
  export DISTRO=""
else
  export OS_TYPE="linux"
  # Detect Linux distro
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    case "$ID" in
      centos|rhel|fedora)  export DISTRO="centos" ;;
      ubuntu|debian)       export DISTRO="ubuntu" ;;
      arch|manjaro)        export DISTRO="arch" ;;
      *)                   export DISTRO="" ;;
    esac
  else
    export DISTRO=""
  fi
fi

# =============================================================================
# Shell Options
# =============================================================================

# Don't complete aliases (useful for git aliases)
setopt no_complete_aliases

# History configuration
export HISTFILE=~/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY          # Write the history file in :start:elapsed;command format
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file

# =============================================================================
# Environment Variables
# =============================================================================

# Set PATH
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

# Detect Homebrew prefix and configure (macOS only)
if [ "$OS_TYPE" = "macos" ]; then
  if [ -d "/opt/homebrew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  elif [ -d "/usr/local/Homebrew" ]; then
    HOMEBREW_PREFIX="/usr/local"
  fi
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi

# Language environment
export LANG=en_US.UTF-8

# Preferred editor
export EDITOR='vim'

# Compilation flags (macOS only)
if [ "$OS_TYPE" = "macos" ]; then
  export ARCHFLAGS="-arch arm64"
fi

# =============================================================================
# Load Modular Environment Configuration
# =============================================================================

# Source all env files from env.d in numeric order (like boot.d)
# Files are organized in subdirectories with override logic:
#   common/           - Files loaded on all platforms
#   $OS_TYPE/         - OS-specific files (macos/ or linux/)
#   ${OS_TYPE}_${DISTRO}/ - Distro-specific files (e.g., linux_centos/)
if [ -d ~/.env.d ]; then
  # Collect env files with override logic
  typeset -A env_files  # Associative array: filename -> full_path

  # First, collect from common/
  if [ -d ~/.env.d/common ]; then
    for env_file in ~/.env.d/common/*.env(N); do
      local filename=$(basename "$env_file")
      env_files[$filename]="$env_file"
    done
  fi

  # Then, collect from OS-specific directory (e.g., macos/ or linux/)
  if [ -d ~/.env.d/$OS_TYPE ]; then
    for env_file in ~/.env.d/$OS_TYPE/*.env(N); do
      local filename=$(basename "$env_file")
      env_files[$filename]="$env_file"  # Override if exists
    done
  fi

  # Finally, collect from distro-specific directory (e.g., linux_centos/)
  if [ -n "$DISTRO" ] && [ -d ~/.env.d/${OS_TYPE}_${DISTRO} ]; then
    for env_file in ~/.env.d/${OS_TYPE}_${DISTRO}/*.env(N); do
      local filename=$(basename "$env_file")
      env_files[$filename]="$env_file"  # Override if exists
    done
  fi

  # Source files in sorted order
  for filename in ${(ko)env_files}; do
    source "${env_files[$filename]}"
  done
fi

# =============================================================================
# Global Aliases
# =============================================================================

if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

# =============================================================================
# Private Configuration
# =============================================================================

# Private zshenv if it exists
if [ -f ~/.zshenv.private ]; then
  source ~/.zshenv.private
fi

# =============================================================================
# Utility Functions and Aliases
# =============================================================================

# Reload the shell
alias reload="exec ${SHELL} -l"

# Start ssh-agent
eval "$(ssh-agent)" &>/dev/null
