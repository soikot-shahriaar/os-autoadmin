#!/bin/bash

# OS-AutoAdmin: Disk Monitor

CONFIG_FILE="$HOME/os-autoadmin/config/osl.conf"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

LOG_FILE="$LOG_DIR/disk_monitor.log"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_menu() {
    clear
    echo "===== OS-AutoAdmin: Disk Monitor ====="
    echo "1) Quick check (summary + warnings)"
    echo "2) Show detailed disk usage (df -h)"
    echo "3) View last 20 log entries"
    echo "4) Exit"
    echo "======================================"
    read -rp "Enter your choice: " choice
}

quick_check() {
    echo
    echo "Running quick disk usage check..."
    echo
    log "Started quick disk check"

    # Show header for our own summary
    printf "%-25s %-10s %-10s\n" "Mount Point" "Used%" "Status"
    echo "-----------------------------------------------"

    # df -P gives POSIX format (easier to parse)
    df -P | awk 'NR>1 {print $5 " " $6}' | while read -r usage mount; do
        # usage is like "65%"
        percent=${usage%%%}  # remove the '%' sign

        status="OK"

        if [ "$percent" -ge "$DISK_CRIT" ]; then
            status="CRITICAL"
            echo "CRITICAL: $mount is ${percent}% full"
            log "CRITICAL: $mount usage at ${percent}%"
        elif [ "$percent" -ge "$DISK_WARN" ]; then
            status="WARNING"
            echo "WARNING:  $mount is ${percent}% full"
            log "WARNING: $mount usage at ${percent}%"
        fi

        # Print table row
        printf "%-25s %-10s %-10s\n" "$mount" "${percent}%" "$status"
    done

    echo
    echo "Quick check completed."
    log "Completed quick disk check"
    read -rp "Press Enter to continue..."
}

detailed_view() {
    echo
    echo "Detailed disk usage (df -h):"
    echo
    df -h
    log "Displayed detailed disk usage (df -h)"
    echo
    read -rp "Press Enter to continue..."
}

view_logs() {
    echo
    echo "Last 20 log entries from $LOG_FILE:"
    echo
    if [ -f "$LOG_FILE" ]; then
        tail -n 20 "$LOG_FILE"
    else
        echo "No log file found yet."
    fi
    echo
    read -rp "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    case "$choice" in
        1) quick_check ;;
        2) detailed_view ;;
        3) view_logs ;;
        4) echo "Exiting Disk Monitor."; exit 0 ;;
        *) echo "Invalid choice. Try again."; sleep 1 ;;
    esac
done
