#!/bin/bash
# Brutalist theme toggle — syncs Waybar + Hyprland + Kitty + Fastfetch + Starship
# Usage: ./theme.sh dark | ./theme.sh light | ./theme.sh toggle

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/brutalist-theme"
WAYBAR_DIR="$HOME/.config/waybar"
HYPR_DIR="$HOME/.config/hypr"
KITTY_DIR="$HOME/.config/kitty"
FASTFETCH_DIR="$HOME/.config/fastfetch"
STARSHIP_DIR="$HOME/.config"

get_current() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    echo "dark"
  fi
}

set_theme() {
  local theme="$1"

  # Waybar colors
  ln -sf "colors-${theme}.css" "${WAYBAR_DIR}/colors.css"

  # Hyprland colors
  ln -sf "colors-${theme}.conf" "${HYPR_DIR}/colors.conf"

  # Kitty colors
  ln -sf "colors-${theme}.conf" "${KITTY_DIR}/colors.conf"

  # Live-reload running kitty instances
  for sock in /tmp/kitty-*; do
    [ -e "$sock" ] && kitty @ --to "unix:$sock" set-colors --all --configured "${KITTY_DIR}/colors-${theme}.conf" 2>/dev/null
  done

  # Fastfetch colors
  ln -sf "config-${theme}.jsonc" "${FASTFETCH_DIR}/config.jsonc"

  # Starship colors
  ln -sf "starship-${theme}.toml" "${STARSHIP_DIR}/starship.toml"

  # Persist
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$theme" > "$STATE_FILE"

  # Reload Hyprland (re-reads sourced configs)
  hyprctl reload 2>/dev/null

  # Reload Waybar
  pkill -x waybar 2>/dev/null
  waybar &
  disown

  echo "Switched to ${theme}"
}

case "${1:-toggle}" in
  dark|light)
    set_theme "$1"
    ;;
  toggle)
    current="$(get_current)"
    if [ "$current" = "dark" ]; then
      set_theme "light"
    else
      set_theme "dark"
    fi
    ;;
  *)
    echo "Usage: $0 {dark|light|toggle}"
    exit 1
    ;;
esac
