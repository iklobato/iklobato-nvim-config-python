#!/bin/bash

# Homebrew Package Import Script
# Imports all packages from a Brewfile

set -e

# Default values
INPUT_FILE="${HOMEBREW_BUNDLE_FILE:-system/Brewfile}"
DRY_RUN=false
FORCE=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --file|-f)
      INPUT_FILE="$2"
      shift 2
      ;;
    --dry-run|-n)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Import all Homebrew packages from a Brewfile"
      echo ""
      echo "Options:"
      echo "  -f, --file FILE        Input Brewfile path (default: Brewfile)"
      echo "  -n, --dry-run          Show what would be installed without installing"
      echo "  --force                Install packages even if already installed"
      echo "  -h, --help             Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  HOMEBREW_BUNDLE_FILE   Default input file location"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Resolve input file path
if [[ "$INPUT_FILE" != /* ]]; then
  # Relative path - use repo root
  INPUT_FILE="$REPO_ROOT/$INPUT_FILE"
fi

# Check if brew is installed
if ! command -v brew &> /dev/null; then
  echo "Error: Homebrew is not installed"
  echo "Install Homebrew first: https://brew.sh"
  exit 1
fi

# Check if Brewfile exists
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Brewfile not found at: $INPUT_FILE"
  echo ""
  echo "To create a Brewfile, run:"
  echo "  ./scripts/brew-export.sh"
  exit 1
fi

echo "Importing Homebrew packages from: $INPUT_FILE"
echo ""

# Count packages in Brewfile
FORMULA_COUNT=$(grep -c "^brew \"" "$INPUT_FILE" 2>/dev/null || echo "0")
CASK_COUNT=$(grep -c "^cask \"" "$INPUT_FILE" 2>/dev/null || echo "0")
TAP_COUNT=$(grep -c "^tap \"" "$INPUT_FILE" 2>/dev/null || echo "0")
MAS_COUNT=$(grep -c "^mas \"" "$INPUT_FILE" 2>/dev/null || echo "0")

# Remove any whitespace/newlines from counts
FORMULA_COUNT=$(echo "$FORMULA_COUNT" | tr -d '[:space:]')
CASK_COUNT=$(echo "$CASK_COUNT" | tr -d '[:space:]')
TAP_COUNT=$(echo "$TAP_COUNT" | tr -d '[:space:]')
MAS_COUNT=$(echo "$MAS_COUNT" | tr -d '[:space:]')

echo "Found in Brewfile:"
echo "  Formulas: $FORMULA_COUNT"
echo "  Casks: $CASK_COUNT"
echo "  Taps: $TAP_COUNT"
if [[ $MAS_COUNT -gt 0 ]]; then
  echo "  Mac App Store apps: $MAS_COUNT"
fi
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN MODE - No packages will be installed"
  echo ""
  echo "Packages that would be installed:"
  echo ""
  
  # Show taps
  if [[ $TAP_COUNT -gt 0 ]]; then
    echo "Taps:"
    grep "^tap \"" "$INPUT_FILE" | sed 's/^tap "/  - /' | sed 's/"$//'
    echo ""
  fi
  
  # Show formulas
  if [[ $FORMULA_COUNT -gt 0 ]]; then
    echo "Formulas:"
    grep "^brew \"" "$INPUT_FILE" | sed 's/^brew "/  - /' | sed 's/"$//'
    echo ""
  fi
  
  # Show casks
  if [[ $CASK_COUNT -gt 0 ]]; then
    echo "Casks:"
    grep "^cask \"" "$INPUT_FILE" | sed 's/^cask "/  - /' | sed 's/"$//'
    echo ""
  fi
  
  # Show MAS apps
  if [[ $MAS_COUNT -gt 0 ]]; then
    echo "Mac App Store apps:"
    grep "^mas \"" "$INPUT_FILE" | sed 's/^mas "/  - /' | sed 's/" #.*$//' | sed 's/"$//'
    echo ""
  fi
  
  echo "To actually install, run without --dry-run flag"
  exit 0
fi

# Check if packages are already installed
if [[ "$FORCE" != "true" ]]; then
  echo "Checking which packages are already installed..."
  MISSING_TAPS=0
  MISSING_FORMULAS=0
  MISSING_CASKS=0
  
  # Check taps
  while IFS= read -r line || [[ -n "$line" ]]; do
    tap_name=$(echo "$line" | sed 's/^tap "//' | sed 's/"$//')
    if [[ -n "$tap_name" ]] && ! brew tap 2>/dev/null | grep -q "^$tap_name$"; then
      MISSING_TAPS=$((MISSING_TAPS + 1))
    fi
  done < <(grep "^tap \"" "$INPUT_FILE" 2>/dev/null || true)
  
  # Check formulas
  while IFS= read -r line || [[ -n "$line" ]]; do
    formula_name=$(echo "$line" | sed 's/^brew "//' | sed 's/"$//')
    if [[ -n "$formula_name" ]] && ! brew list --formula 2>/dev/null | grep -q "^$formula_name$"; then
      MISSING_FORMULAS=$((MISSING_FORMULAS + 1))
    fi
  done < <(grep "^brew \"" "$INPUT_FILE" 2>/dev/null || true)
  
  # Check casks
  while IFS= read -r line || [[ -n "$line" ]]; do
    cask_name=$(echo "$line" | sed 's/^cask "//' | sed 's/"$//')
    if [[ -n "$cask_name" ]] && ! brew list --cask 2>/dev/null | grep -q "^$cask_name$"; then
      MISSING_CASKS=$((MISSING_CASKS + 1))
    fi
  done < <(grep "^cask \"" "$INPUT_FILE" 2>/dev/null || true)
  
  if [[ ${MISSING_TAPS:-0} -eq 0 ]] && [[ ${MISSING_FORMULAS:-0} -eq 0 ]] && [[ ${MISSING_CASKS:-0} -eq 0 ]]; then
    echo "All packages are already installed!"
    echo ""
    echo "To reinstall anyway, use --force flag"
    exit 0
  fi
  
  echo "Packages to install:"
  echo "  Taps: $MISSING_TAPS"
  echo "  Formulas: $MISSING_FORMULAS"
  echo "  Casks: $MISSING_CASKS"
  echo ""
fi

# Confirm installation
echo "This will install packages from the Brewfile."
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Installation cancelled"
  exit 0
fi

echo ""
echo "Installing packages..."
echo ""

# Install using brew bundle
BUNDLE_ARGS="--file=\"$INPUT_FILE\""
if [[ "$FORCE" == "true" ]]; then
  BUNDLE_ARGS="$BUNDLE_ARGS --force"
fi

# Run brew bundle install
if eval "brew bundle install $BUNDLE_ARGS"; then
  echo ""
  echo "Installation complete!"
  echo ""
  echo "Installed packages:"
  echo "  Formulas: $FORMULA_COUNT"
  echo "  Casks: $CASK_COUNT"
  echo "  Taps: $TAP_COUNT"
  if [[ $MAS_COUNT -gt 0 ]]; then
    echo "  Mac App Store apps: $MAS_COUNT"
  fi
else
  echo ""
  echo "Installation completed with some errors."
  echo "Some packages may have failed to install."
  echo "Check the output above for details."
  exit 1
fi

