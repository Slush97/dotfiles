#!/bin/bash
# Deploy dotfiles via GNU stow
# Usage: ./install.sh [package ...]
# With no args, installs all packages.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

PACKAGES=(shell git hypr kitty waybar dunst fastfetch starship nvim btop htop ranger sddm scry npm scripts)

if [ $# -gt 0 ]; then
  PACKAGES=("$@")
fi

# Check for stow
if ! command -v stow &>/dev/null; then
  echo "GNU stow is required: sudo pacman -S stow"
  exit 1
fi

# Stow each package
for pkg in "${PACKAGES[@]}"; do
  if [ -d "$pkg" ]; then
    echo "Stowing $pkg..."
    stow --restow "$pkg"
  else
    echo "Skipping $pkg (not found)"
  fi
done

# Set up theme runtime symlinks (default to current state or light)
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/brutalist-theme"
if [ -f "$STATE_FILE" ]; then
  THEME=$(cat "$STATE_FILE")
else
  THEME="light"
fi

echo "Activating $THEME theme..."
ln -sf "colors-${THEME}.conf" "$HOME/.config/hypr/colors.conf"
ln -sf "colors-${THEME}.conf" "$HOME/.config/kitty/colors.conf"
ln -sf "colors-${THEME}.css"  "$HOME/.config/waybar/colors.css"
ln -sf "config-${THEME}.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ln -sf "starship-${THEME}.toml" "$HOME/.config/starship.toml"

echo "Done. All packages stowed, $THEME theme active."
