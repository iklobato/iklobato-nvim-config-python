#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/iklobato/iklobato-nvim-config-python.git"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TEMP_DIR=$(mktemp -d)

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Detect if script is running from within the repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN_REPO=false
SOURCE_DIR=""

# Check if we're in the repository by looking for init.lua and install.sh
if [ -f "$SCRIPT_DIR/init.lua" ] && [ -f "$SCRIPT_DIR/install.sh" ]; then
    IN_REPO=true
    SOURCE_DIR="$SCRIPT_DIR"
    print_info "Detected: Running from within repository"
else
    IN_REPO=false
    SOURCE_DIR="$TEMP_DIR"
    print_info "Detected: Running via curl, will clone repository"
fi

# Check if Neovim config directory already exists
if [ -d "$NVIM_CONFIG_DIR" ]; then
    print_info "Existing Neovim configuration found at $NVIM_CONFIG_DIR"
    echo -n "Do you want to backup the existing config? (y/n): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        BACKUP_DIR="${NVIM_CONFIG_DIR}.bak_$(date +%Y%m%d%H%M%S)"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        print_success "Existing config backed up to $BACKUP_DIR"
    else
        print_info "Installation cancelled. Existing config will not be modified."
        exit 0
    fi
fi

# Create config directory
mkdir -p "$NVIM_CONFIG_DIR"

# Clone repository only if not running from repo
if [ "$IN_REPO" = false ]; then
    print_info "Cloning Neovim configuration repository..."
    if git clone --depth=1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository. Please check your internet connection and Git installation."
        exit 1
    fi
fi

# Copy files to Neovim config directory
print_info "Installing configuration files..."
cp -r "$SOURCE_DIR"/* "$NVIM_CONFIG_DIR/" 2>/dev/null || {
    print_error "Failed to copy configuration files"
    exit 1
}

# Make install script executable if it exists
if [ -f "$NVIM_CONFIG_DIR/install.sh" ]; then
    chmod +x "$NVIM_CONFIG_DIR/install.sh"
fi

# Success message
echo ""
print_success "Neovim configuration installed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Launch Neovim: nvim"
echo "  2. Plugins will be automatically installed by lazy.nvim"
echo "  3. Wait for the plugin installation to complete"
echo ""
print_info "Configuration location: $NVIM_CONFIG_DIR"

