. "$HOME/.cargo/env"

# Ensure XDG_DATA_DIRS includes user local share for rofi drun mode
export XDG_DATA_DIRS="$HOME/.local/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
