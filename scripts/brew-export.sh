#!/bin/bash

# Exports installed Homebrew taps, formulas and casks to a Brewfile. Usage: --help

set -e

OUTPUT_FILE="${HOMEBREW_BUNDLE_FILE:-system/Brewfile}"
INCLUDE_MAS=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

while [[ $# -gt 0 ]]; do
  case $1 in
  --file | -f)
    OUTPUT_FILE="$2"
    shift 2
    ;;
  --include-mas)
    INCLUDE_MAS=true
    shift
    ;;
  --help | -h)
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Export all installed Homebrew packages to a Brewfile"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE        Output file path (default: Brewfile)"
    echo "  --include-mas          Include Mac App Store apps (requires mas-cli)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  HOMEBREW_BUNDLE_FILE   Default output file location"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    echo "Use --help for usage information"
    exit 1
    ;;
  esac
done

if [[ "$OUTPUT_FILE" != /* ]]; then
  OUTPUT_FILE="$REPO_ROOT/$OUTPUT_FILE"
fi

echo "Exporting Homebrew packages to: $OUTPUT_FILE"
echo ""

if ! command -v brew &>/dev/null; then
  echo "Error: Homebrew is not installed"
  exit 1
fi

if [[ -f "$OUTPUT_FILE" ]]; then
  BACKUP_FILE="${OUTPUT_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Backing up existing Brewfile to: $BACKUP_FILE"
  cp "$OUTPUT_FILE" "$BACKUP_FILE"
fi

{
  echo "# Homebrew Package List"
  echo "# Homebrew version: $(brew --version | head -n1)"
  echo "#"
  echo "# To install all packages, run: brew bundle install"
  echo "# To update this file, run: ./scripts/brew-export.sh"
  echo "#"
  echo ""
} >"$OUTPUT_FILE"

echo "Exporting formulas, casks, and taps..."

# dump --force would overwrite the header above, so dump to a temp file and append
TEMP_FILE="${OUTPUT_FILE}.tmp"

if brew bundle dump --file="$TEMP_FILE" --force 2>/dev/null; then
  cat "$TEMP_FILE" >>"$OUTPUT_FILE"
  rm -f "$TEMP_FILE"
else
  echo "Warning: brew bundle dump failed, using alternative method..."

  echo "" >>"$OUTPUT_FILE"
  echo "# Taps" >>"$OUTPUT_FILE"
  brew tap | while read -r tap; do
    echo "tap \"$tap\"" >>"$OUTPUT_FILE"
  done

  # leaves: top-level formulas only, not their dependencies
  echo "" >>"$OUTPUT_FILE"
  echo "# Formulas" >>"$OUTPUT_FILE"
  brew leaves | while read -r formula; do
    echo "brew \"$formula\"" >>"$OUTPUT_FILE"
  done

  echo "" >>"$OUTPUT_FILE"
  echo "# Casks" >>"$OUTPUT_FILE"
  brew list --cask | while read -r cask; do
    echo "cask \"$cask\"" >>"$OUTPUT_FILE"
  done
fi

if [[ "$INCLUDE_MAS" == "true" ]]; then
  if command -v mas &>/dev/null; then
    echo "" >>"$OUTPUT_FILE"
    echo "# Mac App Store Apps" >>"$OUTPUT_FILE"
    mas list | while read -r line; do
      app_id=$(echo "$line" | awk '{print $1}')
      app_name=$(echo "$line" | cut -d' ' -f2-)
      echo "mas \"$app_id\" # $app_name" >>"$OUTPUT_FILE"
    done
  else
    echo "Warning: mas-cli not installed. Install with: brew install mas"
  fi
fi

FORMULA_COUNT=$(grep -c "^brew \"" "$OUTPUT_FILE" 2>/dev/null || echo "0")
CASK_COUNT=$(grep -c "^cask \"" "$OUTPUT_FILE" 2>/dev/null || echo "0")
TAP_COUNT=$(grep -c "^tap \"" "$OUTPUT_FILE" 2>/dev/null || echo "0")
MAS_COUNT=$(grep -c "^mas \"" "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo ""
echo "Export complete!"
echo "  Formulas: $FORMULA_COUNT"
echo "  Casks: $CASK_COUNT"
echo "  Taps: $TAP_COUNT"
if [[ "$INCLUDE_MAS" == "true" ]]; then
  echo "  Mac App Store apps: $MAS_COUNT"
fi
echo ""
echo "Brewfile saved to: $OUTPUT_FILE"
echo ""
echo "To install all packages on another machine, run:"
echo "  brew bundle install --file=\"$OUTPUT_FILE\""
echo ""
echo "Or use the import script:"
echo "  ./scripts/brew-import.sh --file=\"$OUTPUT_FILE\""
