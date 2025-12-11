# ~/.zshrc - Zsh configuration without Oh My Zsh
# Modern setup using Starship prompt and modular env.d configuration

# =============================================================================
# Shell Options
# =============================================================================

# Don't complete aliases (useful for git aliases)
setopt no_complete_aliases

# History configuration
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

# Set PATH, MANPATH, etc., for Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Language environment
export LANG=en_US.UTF-8

# Preferred editor
export EDITOR='vim'

# Compilation flags
export ARCHFLAGS="-arch arm64"

# =============================================================================
# Load Modular Environment Configuration
# =============================================================================

# Source all env files from env.d in numeric order (like boot.d)
# Files are prefixed with numbers to control load order:
#   00-09: Critical initialization (completions, shell options)
#   10-89: Main environment configuration (tools, languages, paths)
#   90-98: Late-loading plugins (fzf-tab, starship)
#   99:    Must load last (syntax highlighting)
if [ -d ~/.env.d ]; then
  for env_file in $(find ~/.env.d/ -name "*.env" | sort); do
    source "$env_file"
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

# =============================================================================
# SDKMan (must be at end)
# =============================================================================

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# =============================================================================
# UV Completion
# =============================================================================

eval "$(uv generate-shell-completion zsh)"
