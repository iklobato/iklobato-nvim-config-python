#!/bin/bash

if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak_$(date +%Y%m%d%H%M%S)"
fi

if [ -d "$HOME/.local/share/nvim" ]; then
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak_$(date +%Y%m%d%H%M%S)"
fi

if [ -d "$HOME/.local/state/nvim" ]; then
    mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak_$(date +%Y%m%d%H%M%S)"
fi

if [ -d "$HOME/.cache/nvim" ]; then
    mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak_$(date +%Y%m%d%H%M%S)"
fi

if [ ! -d "$HOME/git" ]; then
    mkdir "$HOME/git"
fi

cd "$HOME/git"

if [ -d "iklobato-nvim-config-python" ]; then
    rm -rf "iklobato-nvim-config-python"
fi

git clone https://github.com/iklobato/iklobato-nvim-config-python/

mkdir -p "$HOME/.config/nvim"

cp -r "$HOME/git/iklobato-nvim-config-python/"* "$HOME/.config/nvim/"

echo "Neovim configuration installed successfully. Please open Neovim and run :PlugInstall to install plugins."
