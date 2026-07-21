# System Configuration Files

- `zshrc` - Shell configuration
- `Brewfile` - Homebrew packages
- `lazygit.yml` - Lazygit configuration
- `iterm2/com.googlecode.iterm2.plist` - iTerm2 preferences (colors, fonts, Minimum Contrast, etc.)

`scripts/install.sh` links `zshrc` and `lazygit.yml` automatically (and installs
oh-my-zsh plus the zsh-syntax-highlighting plugin the zshrc needs). On macOS it
also points iTerm2 at the versioned prefs folder.

## iTerm2 (macOS)

`install.sh` runs the equivalent of:
```bash
defaults write com.googlecode.iterm2 PrefsCustomFolder -string ~/.config/nvim/system/iterm2
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
```
iTerm2 then reads its prefs from this folder on launch and writes them back on
quit, so every change you make in the UI stays versioned. Restart iTerm2 to
apply. This carries the color scheme, font, and `Minimum Contrast` (set to 0.15
for readable dim ANSI colors on a limited-range external panel).

Thin strokes are a UI toggle (Settings -> Profiles -> Text -> "Use thin strokes
for anti-aliased text"); flip it once and it saves into this folder like anything
else. To reset iTerm back to its own prefs: set `LoadPrefsFromCustomFolder` to
`false`.

## Display color (Samsung C49HG9x)

`scripts/display.sh` applies a neutral work color profile to the external
Samsung via BetterDisplay (contrast/gamma/temperature). It is machine-specific
(matches the display by name) and NOT run by `install.sh` - run it by hand:
```bash
brew install --cask betterdisplay   # once
./scripts/display.sh
```

To link them by hand instead:
```bash
ln -sf ~/.config/nvim/system/zshrc ~/.zshrc
ln -sf ~/.config/nvim/system/lazygit.yml ~/.config/lazygit/config.yml
```

`Brewfile` is a full machine dump, installed only on request:
```bash
./scripts/brew-import.sh
```
