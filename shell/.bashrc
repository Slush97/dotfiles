#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
eval "$(dircolors -b ~/.dir_colors)"
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Recent directories picker - inline tab cycling
if [[ -f "$HOME/.config/bash/recent-dirs-picker.sh" ]]; then
    source "$HOME/.config/bash/recent-dirs-picker.sh"
fi

# Keep TAB on standard completion for normal prompts.
bind '"\C-i": complete'

. "$HOME/.cargo/env"

# Fastfetch on shell start
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

claude() {
    if [[ "$1" == "-d" ]]; then
        shift
        command claude --dangerously-skip-permissions "$@"
    else
        command claude "$@"
    fi
}
