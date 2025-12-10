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

check_nerd_font_installed() {
    # Check if any Nerd Font is installed
    if fc-list | grep -i "nerd font" >/dev/null 2>&1; then
        return 0
    fi
    # Check for common Nerd Font names
    local font_names=("MesloLGS" "FiraCode" "JetBrainsMono" "UbuntuMono" "Hack" "SourceCodePro")
    for font in "${font_names[@]}"; do
        if fc-list | grep -i "$font.*nerd" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

install_nerd_font_ubuntu() {
    print_info "Installing Nerd Font for proper icon display..."
    
    # Create fonts directory
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    # Download Meslo LG Nerd Font (recommended, matches macOS setup)
    print_info "Downloading Meslo LG Nerd Font..."
    local temp_font_dir=$(mktemp -d)
    cd "$temp_font_dir"
    
    # Download Meslo LG Nerd Font from GitHub releases
    if curl -L -o Meslo.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" 2>/dev/null; then
        # Install unzip if not available
        if ! check_command unzip; then
            print_info "Installing unzip..."
            sudo apt-get install -y unzip
        fi
        
        # Extract and install fonts
        unzip -q Meslo.zip -d "$fonts_dir" 2>/dev/null || {
            print_error "Failed to extract font archive"
            rm -rf "$temp_font_dir"
            return 1
        }
        
        # Update font cache
        fc-cache -fv >/dev/null 2>&1
        
        print_success "Meslo LG Nerd Font installed successfully"
        rm -rf "$temp_font_dir"
        return 0
    else
        print_error "Failed to download Nerd Font"
        rm -rf "$temp_font_dir"
        return 1
    fi
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
    
    # Install Nerd Font for proper icon display
    if ! check_nerd_font_installed; then
        install_nerd_font_ubuntu
    else
        print_success "Nerd Font already installed"
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
    if git clone --depth=1 "$REPO_URL" "$TEMP_DIR" 2>&1; then
        # Verify clone was successful by checking for critical files
        if [ ! -f "$TEMP_DIR/init.lua" ] || [ ! -d "$TEMP_DIR/lua" ]; then
            print_error "Repository cloned but critical files are missing. Clone may be incomplete."
            exit 1
        fi
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository. Please check your internet connection and Git installation."
        exit 1
    fi
fi

# Copy files to Neovim config directory
print_info "Installing configuration files..."

# Verify source directory has files
if [ ! -d "$SOURCE_DIR" ] || [ -z "$(ls -A "$SOURCE_DIR" 2>/dev/null)" ]; then
    print_error "Source directory is empty or does not exist: $SOURCE_DIR"
    exit 1
fi

# Copy files with verbose error reporting
if ! cp -r "$SOURCE_DIR"/* "$NVIM_CONFIG_DIR/" 2>/tmp/install-copy-errors.log; then
    print_error "Failed to copy configuration files"
    if [ -f /tmp/install-copy-errors.log ]; then
        cat /tmp/install-copy-errors.log
        rm -f /tmp/install-copy-errors.log
    fi
    exit 1
fi

# Verify critical files were copied
print_info "Verifying installation..."
MISSING_FILES=0
for file in "init.lua" "lua" "README.md"; do
    if [ ! -e "$NVIM_CONFIG_DIR/$file" ]; then
        print_error "Critical file/directory missing: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    print_error "Installation incomplete. $MISSING_FILES critical file(s) missing."
    exit 1
fi

# Make install script executable if it exists
if [ -f "$NVIM_CONFIG_DIR/install.sh" ]; then
    chmod +x "$NVIM_CONFIG_DIR/install.sh"
fi

print_success "Configuration files installed successfully"

# Check font installation status
echo ""
if check_nerd_font_installed; then
    print_success "Nerd Font detected - icons should display correctly"
else
    print_info "Note: Nerd Font not detected. Icons may not display correctly."
    print_info "Run the installation script again or install manually (see README.md)"
fi

# Post-install instructions
echo ""
print_info "IMPORTANT: Terminal Font Configuration Required"
echo ""
echo "To display file icons correctly, configure your terminal to use a Nerd Font:"
echo ""
echo "1. Install a Nerd Font (if not already installed):"
echo "   Font should be installed at: ~/.local/share/fonts/"
echo ""
echo "2. Configure your terminal emulator:"
echo "   - GNOME Terminal: Edit > Preferences > Text > Custom font"
echo "   - Select: 'MesloLGS Nerd Font' or 'MesloLGS NF'"
echo "   - VS Code Terminal: Add to settings.json:"
echo "     \"terminal.integrated.fontFamily\": \"MesloLGS Nerd Font\""
echo ""
echo "3. Restart your terminal after changing the font"
echo ""
echo "Without a Nerd Font, icons will display as incorrect characters."
echo ""

# Final installation verification
echo ""
print_info "Verifying installation..."
INSTALLATION_OK=true

# Check critical files
for file in "init.lua" "lua"; do
    if [ ! -e "$NVIM_CONFIG_DIR/$file" ]; then
        print_error "Missing: $file"
        INSTALLATION_OK=false
    fi
done

# Check dependencies
if ! check_neovim_version; then
    print_error "Neovim 0.10.0+ not found"
    INSTALLATION_OK=false
fi

for cmd in git node rg python3; do
    if ! check_command "$cmd"; then
        print_error "Missing dependency: $cmd"
        INSTALLATION_OK=false
    fi
done

# Success message
echo ""
if [ "$INSTALLATION_OK" = true ]; then
    print_success "Neovim configuration installed successfully!"
    echo ""
    print_info "Installation Summary:"
    echo "  ✓ Configuration files installed"
    echo "  ✓ Dependencies verified"
    if check_nerd_font_installed; then
        echo "  ✓ Nerd Font detected"
    else
        echo "  ⚠ Nerd Font not detected (icons may not display correctly)"
    fi
    echo ""
    print_info "Next steps:"
    echo "  1. Launch Neovim: nvim"
    echo "  2. Plugins will be automatically installed by lazy.nvim"
    echo "  3. Wait for the plugin installation to complete"
    echo ""
    print_info "Configuration location: $NVIM_CONFIG_DIR"
else
    print_error "Installation completed with errors. Please review the messages above."
    exit 1
fi

