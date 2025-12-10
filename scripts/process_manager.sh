#!/bin/bash

# OS-AutoAdmin: Process Manager

# Load config
CONFIG_FILE="$HOME/os-autoadmin/config/osl.conf"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

LOG_FILE="$LOG_DIR/process_manager.log"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_menu() {
    clear
    echo "===== OS-AutoAdmin: Process Manager ====="
    echo "1) Show top processes by CPU"
    echo "2) Show top processes by Memory"
    echo "3) Kill a process by PID"
    echo "4) Exit"
    echo "========================================="
    read -rp "Enter your choice: " choice
}

show_top_cpu() {
    echo
    echo "Top $TOP_N_PROCESSES processes by CPU usage:"
    ps aux --sort=-%cpu | head -n "$((TOP_N_PROCESSES + 1))"
    log "Displayed top $TOP_N_PROCESSES CPU processes"
    read -rp "Press Enter to continue..."
}

show_top_mem() {
    echo
    echo "Top $TOP_N_PROCESSES processes by Memory usage:"
    ps aux --sort=-%mem | head -n "$((TOP_N_PROCESSES + 1))"
    log "Displayed top $TOP_N_PROCESSES Memory processes"
    read -rp "Press Enter to continue..."
}

kill_process() {
    echo
    read -rp "Enter PID to kill: " pid

    if ! kill -0 "$pid" 2>/dev/null; then
        echo "No such process with PID: $pid"
        log "Failed attempt to kill PID $pid (not found)"
        read -rp "Press Enter to continue..."
        return
    fi

    read -rp "Are you sure you want to kill PID $pid? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        # First try graceful kill
        if kill "$pid" 2>/dev/null; then
            echo "Sent TERM signal to PID $pid."
            log "Sent TERM to PID $pid"
        else
            echo "Failed to send TERM to PID $pid."
            log "Failed TERM to PID $pid"
        fi
    else
        echo "Operation cancelled."
        log "User cancelled kill for PID $pid"
    fi

    read -rp "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    case "$choice" in
        1) show_top_cpu ;;
        2) show_top_mem ;;
        3) kill_process ;;
        4) echo "Exiting Process Manager."; exit 0 ;;
        *) echo "Invalid choice. Try again."; sleep 1 ;;
    esac
done
