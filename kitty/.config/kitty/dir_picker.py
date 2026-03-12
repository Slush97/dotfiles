#!/usr/bin/env python3
"""
Kitty kitten for interactive directory picker.
Shows recent directories with tab/shift-tab navigation and enter to select.
"""

import os
import sys

# Add kitty lib to path
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "lib", "kitty"))

from kittens.tui.loop import Loop
from kittens.tui.operations import (
    clear_screen_to_eos,
    cursor,
    set_line_wrapping,
    init,
    screenshot,
)

HISTORY_FILE = os.path.expanduser("~/.cache/kitty_recent_dirs")
MAX_HISTORY = 50


def load_history():
    """Load directory history from file."""
    if not os.path.exists(HISTORY_FILE):
        os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
        return []

    with open(HISTORY_FILE, "r") as f:
        dirs = [line.strip() for line in f if line.strip()]

    # Keep only existing directories
    dirs = [d for d in dirs if os.path.isdir(d)]

    # Remove duplicates while keeping order (most recent first)
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


class DirPicker:
    def __init__(self):
        self.dirs = load_history()
        self.selected_idx = 0
        self.scroll_offset = 0
        self.max_visible = 15

    def draw(self, screen):
        """Draw the directory picker."""
        with screen.cursor() as c:
            # Title
            c.fg.green.bold("Recent Directories")
            c.println()
            c.println("Use ↑↓ or Tab to navigate, Enter to select, Esc to cancel")
            c.fg.gray("─" * 60)
            c.println()
            c.println()

            # Calculate visible range
            end_idx = min(self.scroll_offset + self.max_visible, len(self.dirs))

            # Draw directories
            for i in range(self.scroll_offset, end_idx):
                is_selected = i == self.selected_idx
                d = self.dirs[i]

                if is_selected:
                    c.fg.black.bg.blue("→ ")
                    c.fg.black.bg.blue(f" {i+1}. {d} ")
                    c.println()
                else:
                    c.fg.gray(f"  {i+1}. ")
                    c.fg.white(d)
                    c.println()

            c.println()
            c.fg.gray(f"Showing {self.scroll_offset + 1}-{end_idx} of {len(self.dirs)} directories")

    def on_key(self, key_event):
        """Handle keyboard input."""
        if key_event.matches("down") or key_event.matches("tab"):
            if self.selected_idx < len(self.dirs) - 1:
                self.selected_idx += 1
                if self.selected_idx >= self.scroll_offset + self.max_visible:
                    self.scroll_offset += 1
            return True

        if key_event.matches("up") or key_event.matches("shift+tab"):
            if self.selected_idx > 0:
                self.selected_idx -= 1
                if self.selected_idx < self.scroll_offset:
                    self.scroll_offset -= 1
            return True

        if key_event.matches("enter"):
            if self.dirs:
                self.quit_with_result(self.dirs[self.selected_idx])
            return True

        if key_event.matches("esc"):
            self.quit()
            return True

        if key_event.matches("q"):
            self.quit()
            return True

        return False


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Directory picker kitten")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Add command - call from shell to track directories
    add_parser = subparsers.add_parser("add", help="Add directory to history")
    add_parser.add_argument("directory", help="Directory to add")

    args = parser.parse_args()

    if args.command == "add":
        add_to_history(args.directory)
    else:
        # Run the picker
        picker = DirPicker()

        if not picker.dirs:
            print("No recent directories found. Navigate to some directories first!")
            sys.exit(0)

        def callback():
            pass

        loop = Loop()
        loop.loop(picker.draw, picker.on_key)
        result = loop.return_code

        if result and len(result) > 0:
            print(result[0], end="")


if __name__ == "__main__":
    main()
