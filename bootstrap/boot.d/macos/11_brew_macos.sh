#!/usr/bin/env bash
# Install macOS-specific packages, casks, and utilities
# Only runs on macOS - skipped on Linux

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Go up to dotfiles root and then to util/
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_ROOT/util/common.sh"
# shellcheck disable=SC1091
source "$DOTFILES_ROOT/util/detect_os.sh"

# Exit early if not on macOS
if [ "$OS_TYPE" != "macos" ]; then
	echo "⏩ Skipping macOS-specific packages (not on macOS)"
	exit 0
fi

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

echo "Installing macOS-specific packages and applications..."

# Add Homebrew taps
pkg_add_tap "bramstein/webfonttools" ${dry_run}
pkg_add_tap "koekeishiya/formulae" ${dry_run}
pkg_add_tap "MisterTea/et" ${dry_run}

# Font tools
pkg_install "sfnt2woff" ${dry_run}
pkg_install "sfnt2woff-zopfli" ${dry_run}
pkg_install "woff2" ${dry_run}

# macOS-specific utilities
pkg_install "cliclick" ${dry_run}

# Window management (yabai + skhd from koekeishiya tap)
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) brew install koekeishiya/formulae/yabai"
	echo "(DRY RUN) brew install koekeishiya/formulae/skhd"
else
	# Check if already installed
	if ! brew list yabai &>/dev/null; then
		brew install koekeishiya/formulae/yabai
	else
		echo " ⏩ skip ${bold}yabai${normal}, already installed"
	fi

	if ! brew list skhd &>/dev/null; then
		brew install koekeishiya/formulae/skhd
	else
		echo " ⏩ skip ${bold}skhd${normal}, already installed"
	fi
fi

# Space management
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) brew install spaceid"
else
	if ! brew list spaceid &>/dev/null; then
		brew install spaceid
	else
		echo " ⏩ skip ${bold}spaceid${normal}, already installed"
	fi
fi

# Eternal Terminal (from MisterTea/et tap)
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) brew install MisterTea/et/et"
else
	if ! brew list et &>/dev/null; then
		brew install MisterTea/et/et
	else
		echo " ⏩ skip ${bold}et${normal}, already installed"
	fi
fi

# Network tools (macOS only)
pkg_install "nmap" ${dry_run}
pkg_install "socat" ${dry_run}

# Docker (macOS only)
pkg_install "docker" ${dry_run}

# Quick Look plugin
pkg_install_cask "qlstephen" ${dry_run}

# GUI Applications
pkg_install_cask "alfred" ${dry_run}
pkg_install_cask "firefox" ${dry_run}
pkg_install_cask "homebrew/cask-versions/firefox-developer-edition" ${dry_run}
pkg_install_cask "iterm2" ${dry_run}
pkg_install_cask "visual-studio-code" ${dry_run}
pkg_install_cask "jetbrains-toolbox" ${dry_run}
pkg_install_cask "bartender" ${dry_run}
pkg_install_cask "obsidian" ${dry_run}

echo "✅ macOS-specific packages installation complete!"
