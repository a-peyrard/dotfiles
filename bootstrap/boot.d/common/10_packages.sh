#!/usr/bin/env bash
# Install essential packages for dotfiles (cross-platform)
# Only installs packages needed for shell/editor/terminal functionality
# Skips development tools, GUI apps, and platform-specific packages

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Go up to dotfiles root and then to util/
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_ROOT/util/common.sh"
# shellcheck disable=SC1091
source "$DOTFILES_ROOT/util/detect_os.sh"

dry_run=0

# Extract parameters
while test $# -gt 0
do
	case "$1" in
		--dry-run) dry_run=1
			;;
	esac
	shift
done

echo "Installing essential packages for ${OS_TYPE}..."

# Update package manager
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) pkg_update"
else
	pkg_update
fi

# Upgrade existing packages
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) pkg_upgrade"
else
	pkg_upgrade
fi

# Core shell and editor
pkg_install "git" ${dry_run}
pkg_install "tmux" ${dry_run}
pkg_install "zsh" ${dry_run}
pkg_install "vim" ${dry_run}

# Shell utilities
pkg_install "tree" ${dry_run}
pkg_install "autojump" ${dry_run}
pkg_install "watch" ${dry_run}
pkg_install "jq" ${dry_run}
pkg_install "fzf" ${dry_run}
pkg_install "rsync" ${dry_run}
pkg_install "htop" ${dry_run}
pkg_install "just" ${dry_run}

# Git tools
pkg_install "delta" ${dry_run}
pkg_install "git-lfs" ${dry_run}

# Terminal utilities
pkg_install "glow" ${dry_run}
pkg_install "highlight" ${dry_run}

# Shell plugins
pkg_install "zsh-syntax-highlighting" ${dry_run}
pkg_install "starship" ${dry_run}

# Other utilities
pkg_install "ack" ${dry_run}

# Note: docker is installed separately in macOS-specific script (11_brew_macos.sh)
# Note: eternalterminal requires special handling (Homebrew tap on macOS, may need build on Linux)
# Skip for now - can be added manually or in platform-specific script

# Cleanup
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) pkg_cleanup"
else
	pkg_cleanup
fi

echo "✅ Essential packages installation complete!"
