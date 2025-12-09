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

# OS Detection Function
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
                    echo "ubuntu"
                else
                    echo "linux"
                fi
            else
                echo "linux"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Dependency Check Functions
check_command() {
    command -v "$1" >/dev/null 2>&1
}

check_neovim_version() {
    if check_command nvim; then
        local version=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
        local major=$(echo "$version" | cut -d. -f1)
        local minor=$(echo "$version" | cut -d. -f2)
        if [ "$major" -gt 0 ] || ([ "$major" -eq 0 ] && [ "$minor" -ge 10 ]); then
            return 0  # Version >= 0.10.0
        fi
    fi
    return 1  # Not installed or version too old
}

# Ubuntu Dependency Installation
install_dependencies_ubuntu() {
    print_info "Detected Ubuntu/Debian. Checking dependencies..."
    
    # Check for sudo access
    if ! sudo -n true 2>/dev/null; then
        print_info "Some operations require sudo. You may be prompted for your password."
    fi
    
    # Update package list
    print_info "Updating package list..."
    sudo apt-get update -qq
    
    # Install software-properties-common for add-apt-repository
    if ! check_command add-apt-repository; then
        print_info "Installing software-properties-common..."
        sudo apt-get install -y software-properties-common
    fi
    
    # Install Neovim (from PPA for latest version)
    if ! check_neovim_version; then
        print_info "Installing Neovim 0.10.0+..."
        # Add Neovim PPA for latest version
        sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || {
            print_info "Adding Neovim PPA..."
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
        }
        sudo apt-get update -qq
        sudo apt-get install -y neovim
        print_success "Neovim installed successfully"
    else
        print_success "Neovim 0.10.0+ already installed"
    fi
    
    # Install Git
    if ! check_command git; then
        print_info "Installing Git..."
        sudo apt-get install -y git
        print_success "Git installed"
    else
        print_success "Git already installed"
    fi
    
    # Install Node.js and npm (using NodeSource repository for latest LTS)
    if ! check_command node; then
        print_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        print_success "Node.js installed"
    else
        print_success "Node.js already installed"
    fi
    
    # Install Ripgrep
    if ! check_command rg; then
        print_info "Installing Ripgrep..."
        sudo apt-get install -y ripgrep
        print_success "Ripgrep installed"
    else
        print_success "Ripgrep already installed"
    fi
    
    # Install Python 3
    if ! check_command python3; then
        print_info "Installing Python 3..."
        sudo apt-get install -y python3 python3-pip
        print_success "Python 3 installed"
    else
        print_success "Python 3 already installed"
    fi
}

# macOS Dependency Installation
install_dependencies_macos() {
    print_info "Detected macOS. Checking dependencies..."
    
    # Check if Homebrew is installed
    if ! check_command brew; then
        print_info "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install Neovim (latest version)
    if ! check_neovim_version; then
        print_info "Installing Neovim..."
        brew install neovim
        print_success "Neovim installed"
    else
        print_success "Neovim 0.10.0+ already installed"
    fi
    
    # Install Git
    if ! check_command git; then
        print_info "Installing Git..."
        brew install git
        print_success "Git installed"
    else
        print_success "Git already installed"
    fi
    
    # Install Node.js and npm
    if ! check_command node; then
        print_info "Installing Node.js..."
        brew install node
        print_success "Node.js installed"
    else
        print_success "Node.js already installed"
    fi
    
    # Install Ripgrep
    if ! check_command rg; then
        print_info "Installing Ripgrep..."
        brew install ripgrep
        print_success "Ripgrep installed"
    else
        print_success "Ripgrep already installed"
    fi
    
    # Install Python 3
    if ! check_command python3; then
        print_info "Installing Python 3..."
        brew install python3
        print_success "Python 3 installed"
    else
        print_success "Python 3 already installed"
    fi
}

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

# Detect OS and install dependencies
OS=$(detect_os)
case "$OS" in
    macos)
        install_dependencies_macos
        ;;
    ubuntu)
        install_dependencies_ubuntu
        ;;
    *)
        print_error "Unsupported OS: $(uname -s)"
        print_info "Please install dependencies manually:"
        echo "  - Neovim 0.10.0+"
        echo "  - Git"
        echo "  - Node.js and npm"
        echo "  - Ripgrep"
        echo "  - Python 3"
        echo ""
        read -p "Continue with config installation anyway? (y/n): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        ;;
esac

# Verify Neovim installation
if ! check_neovim_version; then
    print_error "Neovim 0.10.0+ is required but not found. Please install it manually."
    exit 1
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

