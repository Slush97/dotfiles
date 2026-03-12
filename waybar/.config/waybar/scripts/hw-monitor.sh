#!/usr/bin/env bash
# Outputs JSON for waybar custom modules with temperature-based classes
# Usage: hw-monitor.sh cpu|mem|gpu

# Dynamically find coretemp hwmon (Package id 0) — avoids hardcoded hwmon index
HWMON=$(grep -rl "^coretemp$" /sys/class/hwmon/*/name 2>/dev/null | head -1 | xargs -I{} dirname {})
CPU_TEMP=$(( $(cat "${HWMON}/temp1_input" 2>/dev/null || echo 0) / 1000 ))

temp_class() {
    local t=$1
    if   (( t >= 85 )); then echo "critical"
    elif (( t >= 75 )); then echo "hot"
    elif (( t >= 60 )); then echo "warm"
    else echo "normal"
    fi
}

CLASS=$(temp_class "$CPU_TEMP")

# CPU usage: delta between two /proc/stat reads for accurate current usage
cpu_usage() {
    local CACHE="/tmp/waybar-cpu-stat"
    local vals
    vals=$(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat)
    read -r u1 n1 s1 i1 w1 x1 y1 <<< "$vals"
    local prev_total=0 prev_idle=0
    if [[ -f "$CACHE" ]]; then
        read -r prev_total prev_idle < "$CACHE"
    fi
    local idle=$(( i1 + w1 ))
    local total=$(( u1 + n1 + s1 + i1 + w1 + x1 + y1 ))
    local d_total=$(( total - prev_total ))
    local d_idle=$(( idle - prev_idle ))
    echo "$total $idle" > "$CACHE"
    if (( d_total == 0 )); then echo 0; return; fi
    echo $(( (d_total - d_idle) * 100 / d_total ))
}

case "$1" in
    cpu)
        USAGE=$(cpu_usage)
        echo "{\"text\": \"󰍛 ${USAGE}%\", \"tooltip\": \"CPU: ${USAGE}% | ${CPU_TEMP}°C\", \"class\": \"$CLASS\"}"
        ;;
    mem)
        read -r TOTAL AVAIL <<< "$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t, a}' /proc/meminfo)"
        USED=$(( (TOTAL - AVAIL) * 100 / TOTAL ))
        USED_GB=$(awk "BEGIN{printf \"%.1f\", ($TOTAL - $AVAIL) / 1048576}")
        TOTAL_GB=$(awk "BEGIN{printf \"%.1f\", $TOTAL / 1048576}")
        echo "{\"text\": \"󰘚 ${USED}%\", \"tooltip\": \"RAM: ${USED_GB}G / ${TOTAL_GB}G | ${CPU_TEMP}°C\", \"class\": \"$CLASS\"}"
        ;;
    gpu)
        CUR=$(cat /sys/class/drm/card1/gt_cur_freq_mhz 2>/dev/null || echo 0)
        MAX=$(cat /sys/class/drm/card1/gt_max_freq_mhz 2>/dev/null || echo 1)
        PCT=$(( CUR * 100 / MAX ))
        echo "{\"text\": \"󰢮 ${PCT}%\", \"tooltip\": \"GPU: ${CUR}MHz / ${MAX}MHz | ${CPU_TEMP}°C\", \"class\": \"$CLASS\"}"
        ;;
esac
