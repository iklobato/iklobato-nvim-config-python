# System Configuration Files

- `zshrc` - Shell configuration
- `Brewfile` - Homebrew packages
- `lazygit.yml` - Lazygit configuration
- `git/` - global gitconfig, the bluerivertech include, and the global git ignore
- `shell/` - `.zshenv` and `.zprofile` (shell bootstrap that runs before `zshrc`)
- `claude/` - Claude Code config: settings, CLAUDE.md, hooks, agents, skills, commands
- `alacritty/`, `aider/`, `pgcli/` - dev tool configs
- `tor/`, `privoxy/`, `launchagents/` - reference copies (not auto-linked, see below)

`scripts/install.sh` links `zshrc` and `lazygit.yml` automatically (and installs
oh-my-zsh plus the zsh-syntax-highlighting plugin the zshrc needs). `link_dotfiles` and
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

iTerm2 prefs and the Terminal Noir profile are not in this repo any more. They live in
the dotfiles repo (`~/iterm2-dotfiles`, github.com/iklobato/dotfiles): iTerm2 reads
`PrefsCustomFolder=~/iterm2-dotfiles` and writes its prefs back there on quit. The old
copy here (2026-07-21) was stale and `install.sh` would have pointed iTerm2 back to it.

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
