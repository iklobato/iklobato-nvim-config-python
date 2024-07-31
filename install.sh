#!/bin/bash

GITHUB_REPO_URL="https://github.com/iklobato/iklobato-nvim-config-python"
GIT_DIR="$HOME/git"
CONFIG_DIR="$HOME/.config/nvim"
BACKUP_SUFFIX=".bak_$(date +%Y%m%d%H%M%S)"

if [ -d "$CONFIG_DIR" ]; then
    mv "$CONFIG_DIR" "${CONFIG_DIR}${BACKUP_SUFFIX}"
fi

CACHE_DIR="$HOME/.local/share/nvim"
STATE_DIR="$HOME/.local/state/nvim"
NVIM_CACHE_DIR="$HOME/.cache/nvim"

if [ -d "$CACHE_DIR" ]; then
    mv "$CACHE_DIR" "${CACHE_DIR}${BACKUP_SUFFIX}"
fi

if [ -d "$STATE_DIR" ]; then
    mv "$STATE_DIR" "${STATE_DIR}${BACKUP_SUFFIX}"
fi

if [ -d "$NVIM_CACHE_DIR" ]; then
    mv "$NVIM_CACHE_DIR" "${NVIM_CACHE_DIR}${BACKUP_SUFFIX}"
fi

mkdir -p "$GIT_DIR"
cd "$GIT_DIR"

git clone "$GITHUB_REPO_URL" nvim-config

if [ $? -ne 0 ]; then
    echo "Failed to clone the repository. Exiting."
    exit 1
fi

mkdir -p "$CONFIG_DIR"
cp -r "$GIT_DIR/nvim-config/.config/nvim/"* "$CONFIG_DIR/"

echo "Neovim configuration installed successfully."

