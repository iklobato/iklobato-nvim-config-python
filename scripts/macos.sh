#!/usr/bin/env bash
#
# Opinionated macOS system defaults for a dev machine. Run by hand on a new Mac:
#   ./scripts/macos.sh
# Not called by install.sh. Review before running; log out or restart for all of
# it to take effect. Every setting here is reversible via System Settings.
#
set -euo pipefail

[[ "$(uname -s)" == Darwin ]] || { echo "macOS only"; exit 1; }

echo "==> keyboard: fast key repeat, no press-and-hold accent popup"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "==> text: disable auto-correct / smart quotes / auto-capitalize (code-friendly)"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

echo "==> Finder: show extensions, path bar, status bar, POSIX path title, list view"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "==> screenshots: PNG, no window shadow, saved to ~/Screenshots"
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

echo "==> Dock: autohide, small tiles, no recent apps"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock tilesize -int 44
defaults write com.apple.dock show-recents -bool false

echo "==> performance: no window animations, instant Dock, reduced transparency"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.universalaccess reduceTransparency -bool true

echo "==> panels: expand save/print dialogs by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

echo "==> restarting affected apps"
killall Finder Dock SystemUIServer 2>/dev/null || true

echo "done. Some settings need a logout/restart to fully apply."
