#!/usr/bin/env python3
"""
Kitty kitten to show and navigate recent directories.
Press Tab to cycle through directories, Enter to cd to the selected one.
"""

import os
import sys
from kitty.boss import get_boss
from kitty.key_encoding import KeyEvent, KeyEventType

# History file to store recent directories
HISTORY_FILE = os.path.expanduser("~/.cache/kitty_recent_dirs")
MAX_HISTORY = 50

def load_history():
    """Load directory history from file."""
    if not os.path.exists(HISTORY_FILE):
        # Create the cache directory if it doesn't exist
        os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
        return []

    with open(HISTORY_FILE, "r") as f:
        dirs = [line.strip() for line in f if line.strip()]

    # Keep only existing directories
    dirs = [d for d in dirs if os.path.isdir(d)]

    # Remove duplicates while keeping order
    seen = set()
    unique_dirs = []
    for d in dirs:
        if d not in seen:
            seen.add(d)
            unique_dirs.append(d)

    return unique_dirs

def save_history(dirs):
    """Save directory history to file."""
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    with open(HISTORY_FILE, "w") as f:
        for d in dirs:
            f.write(f"{d}\n")

def add_to_history(directory):
    """Add a directory to history."""
    dirs = load_history()

    # Remove if already exists (to move to front)
    if directory in dirs:
        dirs.remove(directory)

    # Add to front
    dirs.insert(0, directory)

    # Trim to max
    dirs = dirs[:MAX_HISTORY]

    save_history(dirs)

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Recent directories for kitty")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Add command
    add_parser = subparsers.add_parser("add", help="Add directory to history")
    add_parser.add_argument("directory", help="Directory to add")

    # Show command
    show_parser = subparsers.add_parser("show", help="Show and select from history")

    args = parser.parse_args()

    if args.command == "add":
        add_to_history(args.directory)
    elif args.command == "show":
        # Get history
        dirs = load_history()

        if not dirs:
            print("No recent directories found.")
            sys.exit(0)

        # Use kitty's built-in launcher or fzf if available
        import subprocess

        try:
            # Try fzf first
            result = subprocess.run(
                ["fzf", "--prompt", "Recent Dirs > ", "--height", "40%"],
                input="\n".join(dirs),
                capture_output=True,
                text=True,
            )
            if result.returncode == 0 and result.stdout.strip():
                selected = result.stdout.strip()
                print(selected)
        except FileNotFoundError:
            # Fallback to simple selector
            print("\n".join(dirs))

if __name__ == "__main__":
    main()
