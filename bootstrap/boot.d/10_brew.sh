#!/usr/bin/env bash
# Install command-line tools using Homebrew.

# some variables for output formatting 
bold=$(tput bold)
normal=$(tput sgr0)

dry_run=0

# extract parameters
while test $# -gt 0
do
	case "$1" in
		--dry-run) dry_run=1
			;;
	esac
	shift
done

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) brew upgrade"
else
	brew upgrade
	brew upgrade --cask
fi

# get the list of installed formulaes and casks
installed_formulaes=()
while IFS=\n read line
do
	installed_formulaes+=($line)
done <<< "$(brew list)"

installed_casks=()
while IFS=\n read line
do
	installed_casks+=($line)
done <<< "$(brew list --cask)"

function containsElement() {
  local e match="$1"
  shift

  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function brew-install() {
	formulae=$1

	if containsElement "${formulae}" "${installed_formulaes[@]}"; then
		echo " ⏩ skip ${bold}${formulae}${normal}, already installed"
	else
		if [[ ${dry_run} == 1 ]]; then
			echo "(DRY RUN) brew install ${formulae}"
		else
			brew install ${formulae}
		fi
	fi
}

function brew-cask-install() {
	cask=$1

	if containsElement "${cask}" "${installed_casks[@]}"; then
		echo " ⏩ skip cask ${bold}${cask}${normal}, already installed"
	else
		if [[ ${dry_run} == 1 ]]; then
			echo "(DRY RUN) brew install --cask ${cask}"
		else
			brew install --cask ${cask}
		fi
	fi
}

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) brew install coreutils"
	echo "(DRY RUN) link coreutils"
else
	brew-install coreutils
	if [[ ! -f ${BREW_PREFIX}/bin/sha256sum ]]; then
		ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"
	fi
fi

# Install some other useful utilities like `sponge`.
brew-install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew-install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew-install gnu-sed --with-default-names
# Install Bash 4.
brew-install bash

# Install GnuPG to enable PGP-signing commits.
brew-install gnupg

# Install more recent versions of some macOS tools.
brew-install vim --with-override-system-vi
brew-install grep
brew-install openssh
brew-install dos2unix
brew-install graphviz

# Install font tools.
brew tap bramstein/webfonttools
brew-install sfnt2woff
brew-install sfnt2woff-zopfli
brew-install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
#brew-install aircrack-ng
#brew-install bfg
#brew-install binutils
#brew-install binwalk
#brew-install cifer
#brew-install dex2jar
#brew-install dns2tcp
#brew-install fcrackzip
#brew-install foremost
#brew-install hashpump
#brew-install hydra
#brew-install john
#brew-install knock
#brew-install netpbm
brew-install nmap
#brew-install pngcheck
brew-install socat
brew-install wget
#brew-install sqlmap
#brew-install tcpflow
#brew-install tcpreplay
#brew-install tcptrace
#brew-install ucspi-tcp # `tcpserver` etc.
#brew-install xpdf
#brew-install xz

# Install other useful binaries.
brew-install ack
#brew-install exiv2
brew-install git
brew-install git-lfs
brew-install diff-so-fancy
#brew-install imagemagick --with-webp
#brew-install lua
#brew-install lynx
#brew-install p7zip
#brew-install pigz
#brew-install pv
#brew-install rename
#brew-install rlwrap
#brew-install ssh-copy-id
brew-install tree
#brew-install vbindiff
#brew-install zopfli
brew-install autojump
brew-install safe-rm
brew-install autojump
brew-install watch
brew-install yank
brew-install fx
brew-install jq
brew-install fzf
brew-install zlib
brew-install rsync
brew-install htop
brew-install highlight

# python 3 dev
brew-install python
brew-install pyenv
brew-install pyenv-virtualenvwrapper

# go
brew-install go

# ML
brew-install octave

# java & friends
brew-cask-install java
brew-install kotlin
brew-install scala
brew-install sbt
brew-install clojure
brew-install leiningen
brew-install gradle
brew-install gradle-completion

# other dev languages
brew-install ocaml

# js dev
brew-install node

# middlewares
#brew-install apache-spark
#brew-install kafka

# mongo
#brew tap mongodb/brew
#brew-install mongodb/brew/mongodb-community@3.6
#brew-cask-install robo-3t

#brew-install postgresql

# tune macos "quick look" to handle more files
brew-cask-install qlstephen

# tmux
brew-install tmux
brew-install cliclick

# zsh
brew-install zsh
brew-install rbenv
brew-install zsh-syntax-highlighting

# docker
brew-install docker


# some macos apps
brew-cask-install alfred
#brew-cask-install hammerspoon
#brew-cask-install yakyak
brew-cask-install firefox
brew-cask-install homebrew/cask-versions/firefox-developer-edition
#brew-cask-install evernote
#brew-cask-install spectacle
brew-cask-install iterm2
brew-cask-install visual-studio-code
#brew-cask-install bitbar
brew-cask-install jetbrains-toolbox
brew-cask-install bartender # remove space from menu bar

# Remove outdated versions from the cellar.
if [[ ${dry_run} == 1 ]]; then
	echo "(DRY RUN) cleanup"
else
	brew cleanup
fi
