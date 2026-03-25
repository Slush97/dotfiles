# dotfiles

Personal configuration files for an Arch Linux + Hyprland setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package | Description |
|---------|-------------|
| **shell** | Bash config (`.bashrc`, `.bash_profile`, `.dir_colors`) with Starship prompt and fastfetch on startup |
| **hypr** | Hyprland window manager config with light/dark color schemes and a scry-dictate modifier suppress submap |
| **kitty** | Kitty terminal with JetBrains Mono, 90% opacity, light/dark themes, and a recent-dirs picker |
| **waybar** | Waybar status bar with hardware monitor, blue light filter scripts, and a global theme toggle |
| **dunst** | Dunst notification daemon |
| **nvim** | Neovim (lazy.nvim) for Python, Rust, and R with native LSP, nvim-cmp, Telescope, Treesitter, SnipRun, and REPL keybindings |
| **starship** | Starship prompt with light and dark variants |
| **fastfetch** | Fastfetch system info with custom ASCII logo and light/dark configs |
| **btop** | btop++ resource monitor |
| **htop** | htop process viewer |
| **ranger** | Ranger file manager |
| **scry** | Scry dictation tool config |
| **sddm** | Custom SDDM login theme (brutalist glass panel, QML) |
| **git** | Git config and global ignore |
| **npm** | npm config (global prefix) |
| **scripts** | Utility scripts — Android debloat via ADB, asusctl fan control (`fan-status`, `fan-set`, `fan-auto`, `fan-watch`) |

## Theme system

A unified light/dark theme toggle syncs colors across Hyprland, Kitty, Waybar, Fastfetch, and Starship:

```bash
~/.config/waybar/scripts/../theme.sh toggle   # swap light <-> dark
~/.config/waybar/scripts/../theme.sh dark      # force dark
~/.config/waybar/scripts/../theme.sh light     # force light
```

Current theme is persisted in `~/.local/state/brutalist-theme`. Kitty instances are live-reloaded over their unix sockets.

## Install

Requires [GNU Stow](https://www.gnu.org/software/stow/).

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# Install everything
./install.sh

# Or pick specific packages
./install.sh kitty nvim shell
```

The install script stows each package into `$HOME` and activates the current (or default light) theme by creating the appropriate symlinks.

## Dependencies

- **WM**: Hyprland
- **Terminal**: Kitty
- **Shell**: Bash + Starship
- **Editor**: Neovim 0.11+ (native LSP)
- **Font**: JetBrains Mono / JetBrainsMono Nerd Font
- **Display manager**: SDDM
- **Other**: waybar, dunst, fastfetch, btop, htop, ranger, scry
