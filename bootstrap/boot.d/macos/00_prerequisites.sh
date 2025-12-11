#!/usr/bin/env bash
# macOS prerequisites - install xcode tools and Homebrew

echo "- Installing git from xcode"
xcode-select --install

echo "- init gitsubmodules"
git submodule update --init --recursive

echo "- Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
