# System Configuration Files

- `zshrc` - Shell configuration
- `Brewfile` - Homebrew packages
- `lazygit.yml` - Lazygit configuration
- `iterm2/com.googlecode.iterm2.plist` - iTerm2 preferences (colors, fonts, Minimum Contrast, etc.)
- `git/` - global gitconfig, the bluerivertech include, and the global git ignore
- `shell/` - `.zshenv` and `.zprofile` (shell bootstrap that runs before `zshrc`)
- `claude/` - Claude Code config: settings, CLAUDE.md, hooks, agents, skills, commands
- `alacritty/`, `aider/`, `pgcli/` - dev tool configs
- `tor/`, `privoxy/`, `launchagents/` - reference copies (not auto-linked, see below)

`scripts/install.sh` links `zshrc` and `lazygit.yml` automatically (and installs
oh-my-zsh plus the zsh-syntax-highlighting plugin the zshrc needs). On macOS it
also points iTerm2 at the versioned prefs folder. `link_dotfiles` and
`link_claude` symlink the git, shell, dev-tool, and Claude configs above.

## Not auto-linked (run by hand)

`tor/torrc`, `privoxy/config`, and `launchagents/*.plist` are versioned as
reference only. Their live paths depend on the Homebrew prefix and need a service
reload, so copy them into place by hand on a new machine:

```sh
cp system/tor/torrc "$(brew --prefix)/etc/tor/torrc"
cp system/privoxy/config "$(brew --prefix)/etc/privoxy/config"
cp system/launchagents/*.plist ~/Library/LaunchAgents/   # then: launchctl load
```

The Claude `agents/refs/` pentest clones (159M) and skill `.venv`/cache dirs are
gitignored: only authored config is versioned, not regenerable state.

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
