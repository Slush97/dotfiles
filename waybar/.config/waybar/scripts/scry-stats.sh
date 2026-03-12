#!/usr/bin/env bash
DB="$HOME/.local/share/scry/stats.db"

if [[ ! -f "$DB" ]]; then
    notify-send -a scry-dictate "No stats yet" "No transcriptions recorded"
    exit 0
fi

choice=$(printf "Today's stats\nLast 7 days\nRestart daemon" | rofi -dmenu -p "scry-dictate")

case "$choice" in
    "Today's stats")
        stats=$(sqlite3 "$DB" "SELECT COUNT(*), COALESCE(SUM(word_count),0), COALESCE(ROUND(AVG(inference_ms)),0) FROM transcriptions WHERE date(timestamp)=date('now','localtime');")
        IFS='|' read -r count words avg_ms <<< "$stats"
        notify-send -a scry-dictate "Today" "${count} transcriptions, ${words} words, avg ${avg_ms}ms"
        ;;
    "Last 7 days")
        stats=$(sqlite3 "$DB" "SELECT COUNT(*), COALESCE(SUM(word_count),0), COALESCE(ROUND(AVG(inference_ms)),0) FROM transcriptions WHERE timestamp >= datetime('now','localtime','-7 days');")
        IFS='|' read -r count words avg_ms <<< "$stats"
        notify-send -a scry-dictate "Last 7 days" "${count} transcriptions, ${words} words, avg ${avg_ms}ms"
        ;;
    "Restart daemon")
        pkill -x scry-dictate && sleep 0.5
        notify-send -a scry-dictate "Restarting" "scry-dictate daemon restarting..."
        env LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/latest/lib/intel64 scry-dictate --model "$HOME/esolearn/crates/scry-stt/models/whisper-tiny" &
        disown
        ;;
esac
