#!/bin/bash
# Recent directories tracker and picker for kitty
# Usage: Add to shell config to auto-track directories, bind in kitty.conf

HISTORY_FILE="$HOME/.cache/kitty_recent_dirs"
MAX_HISTORY=50

# Create cache dir if needed
mkdir -p "$(dirname "$HISTORY_FILE")"

add_to_history() {
    local dir="$1"
    # Don't add home dir to history
    [ "$dir" = "$HOME" ] && return

    # Create temp file
    local tmp_file="${HISTORY_FILE}.tmp"

    # Add new dir to front of history
    echo "$dir" > "$tmp_file"

    # Append existing dirs, skipping duplicates
    if [ -f "$HISTORY_FILE" ]; then
        grep -vxF "$dir" "$HISTORY_FILE" | head -n $((MAX_HISTORY - 1)) >> "$tmp_file"
    fi

    mv "$tmp_file" "$HISTORY_FILE"
}

# Remove non-existent dirs from history
cleanup_history() {
    if [ ! -f "$HISTORY_FILE" ]; then
        return
    fi

    local tmp_file="${HISTORY_FILE}.tmp"
    while IFS= read -r dir; do
        [ -d "$dir" ] && echo "$dir"
    done < "$HISTORY_FILE" > "$tmp_file"

    mv "$tmp_file" "$HISTORY_FILE"
}

show_recent_dirs() {
    cleanup_history

    if [ ! -f "$HISTORY_FILE" ] || [ ! -s "$HISTORY_FILE" ]; then
        echo "No recent directories found."
        return
    fi

    local selected_dir
    if selected_dir=$(fzf --prompt="Recent Dirs > " \
                          --height=40% \
                          --layout=reverse \
                          --border \
                          --no-multi \
                          < "$HISTORY_FILE"); then
        echo "$selected_dir"
    fi
}

# Command line interface
case "${1:-}" in
    add)
        add_to_history "$2"
        ;;
    show)
        show_recent_dirs
        ;;
    cleanup)
        cleanup_history
        ;;
    *)
        echo "Usage: $0 {add|show|cleanup} [directory]"
        exit 1
        ;;
esac
