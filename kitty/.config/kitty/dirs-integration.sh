#!/bin/bash
# Shell integration for tracking recent directories
# Source this in your ~/.bashrc or ~/.zshrc

# Path to the recent dirs script
RECENT_DIRS_SCRIPT="$HOME/.config/kitty/recent-dirs.sh"

# Function to change directory and track it
cd() {
    builtin cd "$@" && $RECENT_DIRS_SCRIPT add "$(pwd)"
}

# Initial tracking
$RECENT_DIRS_SCRIPT add "$(pwd)"
