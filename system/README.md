# System Configuration Files

- `zshrc` - Shell configuration
- `Brewfile` - Homebrew packages
- `lazygit.yml` - Lazygit configuration

`scripts/install.sh` links `zshrc` and `lazygit.yml` automatically (and installs
oh-my-zsh plus the zsh-syntax-highlighting plugin the zshrc needs).

To link them by hand instead:
```bash
ln -sf ~/.config/nvim/system/zshrc ~/.zshrc
ln -sf ~/.config/nvim/system/lazygit.yml ~/.config/lazygit/config.yml
```

`Brewfile` is a full machine dump, installed only on request:
```bash
./scripts/brew-import.sh
```
