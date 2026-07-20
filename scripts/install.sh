#!/usr/bin/env bash
#
# Installs this Neovim config + the system dotfiles from scratch.
#
#   Local:  ./scripts/install.sh [--no-dotfiles]
#   Remote: curl -fsSL https://raw.githubusercontent.com/iklobato/iklobato-nvim-config-python/main/scripts/install.sh | bash
#
set -euo pipefail

REPO_URL="https://github.com/iklobato/iklobato-nvim-config-python.git"
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"

NVIM_MIN_MINOR=11
NODE_MIN_MAJOR=22

MASON_TOOLS=(lua-language-server pyright ruff typescript-language-server stylua debugpy)

INSTALL_DOTFILES=true
if [[ "${1:-}" == "--no-dotfiles" ]]; then
  INSTALL_DOTFILES=false
fi

LOG_FILE="${LOG_FILE:-$HOME/nvim-install-$(date +%Y%m%d-%H%M%S).log}"

setup_logging() {
  : >"$LOG_FILE"
  exec > >(tee -a "$LOG_FILE") 2>&1
  exec 3>>"$LOG_FILE"
  export BASH_XTRACEFD=3
  export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main}: '
  set -x
}

say() { echo "==> $(date +%H:%M:%S) $1"; }
has() { command -v "$1" >/dev/null 2>&1; }

nvim_ok() {
  has nvim || return 1
  local version
  version="$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)"
  [[ "${version%%.*}" -gt 0 ]] && return 0
  [[ "${version##*.}" -ge "$NVIM_MIN_MINOR" ]]
}

node_ok() {
  has node || return 1
  [[ "$(node --version | sed 's/^v//' | cut -d. -f1)" -ge "$NODE_MIN_MAJOR" ]]
}

backup_path() {
  local target="$1" backup
  [[ -e "$target" || -L "$target" ]] || return 0
  if [[ -L "$target" ]]; then
    rm -f "$target"
    return 0
  fi
  backup="${target}.bak_$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  say "backed up $target -> $backup"
}

link_file() {
  local src="$1" dest="$2"
  if [[ "$(readlink "$dest" 2>/dev/null)" == "$src" ]]; then
    return 0
  fi
  backup_path "$dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  say "linked $dest"
}

install_deps_macos() {
  if ! has brew; then
    say "installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi

  nvim_ok || brew install neovim
  has git || brew install git
  node_ok || install_node_macos
  has rg || brew install ripgrep
  has python3 || brew install python3
  has delta || brew install git-delta
  brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1 ||
    brew install --cask font-meslo-lg-nerd-font
}

install_node_macos() {
  brew install "node@${NODE_MIN_MAJOR}"
  brew link --overwrite --force "node@${NODE_MIN_MAJOR}" || true
  if ! node_ok; then
    PATH="$(brew --prefix)/opt/node@${NODE_MIN_MAJOR}/bin:$PATH"
    export PATH
  fi
}

apt_get() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o Dpkg::Options::=--force-confold \
    -o Dpkg::Options::=--force-confdef "$@"
}

install_deps_ubuntu() {
  say "installing dependencies (sudo may ask for your password)"
  apt_get update -qq || true
  apt_get install software-properties-common curl git unzip build-essential \
    ripgrep python3 python3-pip python3-venv git-delta

  if ! nvim_ok; then
    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:neovim-ppa/unstable
    apt_get update -qq || true
    apt_get install neovim
  fi

  if ! node_ok; then
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MIN_MAJOR}.x" | sudo -E bash -
    apt_get install nodejs
  fi

  if ! fc-list 2>/dev/null | grep -qi "nerd font"; then
    say "installing Meslo LG Nerd Font"
    mkdir -p "$HOME/.local/share/fonts"
    curl -fsSL -o /tmp/Meslo.zip \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    unzip -qo /tmp/Meslo.zip -d "$HOME/.local/share/fonts"
    fc-cache -f >/dev/null 2>&1 || true
  fi
}

place_config() {
  local repo_root
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

  if [[ ! -f "$repo_root/init.lua" ]]; then
    backup_path "$NVIM_CONFIG_DIR"
    mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
    git clone --depth=1 "$REPO_URL" "$NVIM_CONFIG_DIR"
    return 0
  fi

  if [[ "$(cd "$NVIM_CONFIG_DIR" 2>/dev/null && pwd -P)" == "$repo_root" ]]; then
    return 0
  fi

  backup_path "$NVIM_CONFIG_DIR"
  mkdir -p "$NVIM_CONFIG_DIR"
  cp -R "$repo_root/." "$NVIM_CONFIG_DIR/"
  say "config installed to $NVIM_CONFIG_DIR"
}

install_dotfiles() {
  local system_dir="$NVIM_CONFIG_DIR/system"

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    say "installing oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
  fi

  local highlight_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  [[ -d "$highlight_dir" ]] ||
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$highlight_dir"

  link_file "$system_dir/zshrc" "$HOME/.zshrc"
  if [[ "$(uname -s)" == Darwin ]]; then
    link_file "$system_dir/lazygit.yml" "$HOME/Library/Application Support/lazygit/config.yml"
  else
    link_file "$system_dir/lazygit.yml" "${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/config.yml"
  fi
}

bootstrap_plugins() {
  say "installing plugins"
  nvim --headless "+Lazy! sync" +qa

  local script=/tmp/mason_bootstrap.lua
  cat >"$script" <<EOF
require("lsp")
local registry = require("mason-registry")
registry.refresh()

local tools = { $(printf '"%s", ' "${MASON_TOOLS[@]}") }

local pending = {}
for _, name in ipairs(tools) do
  local found, pkg = pcall(registry.get_package, name)
  if found and not pkg:is_installed() then
    pending[name] = true
    pkg:install():once("closed", function()
      pending[name] = nil
    end)
  end
end

vim.wait(10 * 60 * 1000, function()
  return vim.tbl_isempty(pending)
end, 500)

local failed = {}
for _, name in ipairs(tools) do
  local found, pkg = pcall(registry.get_package, name)
  if not found or not pkg:is_installed() then
    table.insert(failed, name)
  end
end

if #failed > 0 then
  io.stderr:write("mason failed to install: " .. table.concat(failed, ", ") .. "\n")
  vim.cmd("cquit")
end
EOF

  say "installing LSP servers, debugpy and formatters"
  nvim --headless -c "luafile $script" -c "qa!" || say "mason incomplete, finishes on first launch"
}

report_state() (
  set +e
  say "final state"
  echo "--- system ---"
  uname -a
  echo "--- versions ---"
  for cmd in nvim node npm rg python3 git delta zsh; do
    printf '%-8s %s\n' "$cmd" "$(command -v "$cmd" || echo MISSING)"
  done
  nvim --version | head -1
  node --version
  echo "--- config ---"
  ls -la "$NVIM_CONFIG_DIR/init.lua"
  echo "--- dotfiles ---"
  ls -la "$HOME/.zshrc" 2>&1
  echo "--- plugins ($(find "$HOME/.local/share/nvim/lazy" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l)) ---"
  ls "$HOME/.local/share/nvim/lazy" 2>&1
  echo "--- mason binaries ---"
  ls "$HOME/.local/share/nvim/mason/bin" 2>&1
  echo "--- expected mason tools ---"
  printf '%s\n' "${MASON_TOOLS[@]}"
  echo "--- config load check ---"
  nvim --headless "+lua vim.cmd('quitall')" 2>&1 && echo "(no output above = clean)"
)

setup_logging
say "log: $LOG_FILE"

case "$(uname -s)" in
  Darwin) install_deps_macos ;;
  Linux) install_deps_ubuntu ;;
  *) echo "Unsupported OS: $(uname -s)" >&2 && exit 1 ;;
esac

place_config
if [[ "$INSTALL_DOTFILES" == true ]]; then
  install_dotfiles
fi
bootstrap_plugins
report_state

say "done. Set your terminal font to 'MesloLGS Nerd Font'."
say "full log: $LOG_FILE"
