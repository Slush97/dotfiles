#!/usr/bin/env bash
# Bluelight filter control for waybar using gammastep
# Click to toggle, scroll to adjust temperature

STATE_FILE="/tmp/waybar-bluelight"
STEP=200
MIN_TEMP=2500
MAX_TEMP=6500
DEFAULT_TEMP=4000

read_state() {
    if [[ -f "$STATE_FILE" ]]; then
        source "$STATE_FILE"
    else
        ENABLED=0
        TEMP=$DEFAULT_TEMP
    fi
}

write_state() {
    printf 'ENABLED=%d\nTEMP=%d\n' "$ENABLED" "$TEMP" > "$STATE_FILE"
}

apply() {
    if (( ENABLED )); then
        gammastep -P -O "$TEMP" &>/dev/null &
    else
        gammastep -x &>/dev/null &
    fi
}

output() {
    if (( ENABLED )); then
        local pct=$(( (MAX_TEMP - TEMP) * 100 / (MAX_TEMP - MIN_TEMP) ))
        local class="warm"
        if (( TEMP <= 3000 )); then
            class="hot"
        elif (( TEMP >= 5500 )); then
            class="cool"
        fi
        printf '{"text": " %dK", "tooltip": "Bluelight filter: %dK\\nScroll to adjust", "class": "%s"}\n' \
            "$TEMP" "$TEMP" "$class"
    else
        printf '{"text": "", "tooltip": "Bluelight filter: off\\nClick to enable", "class": "off"}\n'
    fi
}

read_state

case "${1:-}" in
    toggle)
        ENABLED=$(( !ENABLED ))
        write_state
        apply
        ;;
    up)
        if (( ENABLED )); then
            TEMP=$(( TEMP + STEP ))
            (( TEMP > MAX_TEMP )) && TEMP=$MAX_TEMP
            write_state
            apply
        fi
        ;;
    down)
        if (( ENABLED )); then
            TEMP=$(( TEMP - STEP ))
            (( TEMP < MIN_TEMP )) && TEMP=$MIN_TEMP
            write_state
            apply
        fi
        ;;
esac

output
