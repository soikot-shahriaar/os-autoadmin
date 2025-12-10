#!/bin/bash

# OS-AutoAdmin: Main Menu

# Always resolve the scripts directory correctly,
# even if this script is run from another folder.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo "====================================="
    echo "|      OS-AutoAdmin - Main Menu     |"
    echo "====================================="
    echo "1) Process Manager                  |"
    echo "2) Disk Monitor                     |"
    echo "3) Backup Manager                   |"
    echo "4) User Manager                     |"
    echo "5) Health Monitor                   |"
    echo "6) Exit                             |"
    echo "====================================="
    read -rp "Enter your choice: " choice
}

run_process_manager() {
    if [ -x "$SCRIPT_DIR/process_manager.sh" ]; then
        "$SCRIPT_DIR/process_manager.sh"
    else
        echo "process_manager.sh not found or not executable."
        read -rp "Press Enter to continue..."
    fi
}

run_disk_monitor() {
    if [ -x "$SCRIPT_DIR/disk_monitor.sh" ]; then
        "$SCRIPT_DIR/disk_monitor.sh"
    else
        echo "disk_monitor.sh not found or not executable."
        read -rp "Press Enter to continue..."
    fi
}

run_backup_manager() {
    if [ -x "$SCRIPT_DIR/backup_manager.sh" ]; then
        "$SCRIPT_DIR/backup_manager.sh"
    else
        echo "backup_manager.sh not found or not executable."
        read -rp "Press Enter to continue..."
    fi
}

run_user_manager() {
    if [ -x "$SCRIPT_DIR/user_manager.sh" ]; then
        "$SCRIPT_DIR/user_manager.sh"
    else
        echo "user_manager.sh not found or not executable."
        read -rp "Press Enter to continue..."
    fi
}

run_health_monitor() {
    if [ -x "$SCRIPT_DIR/health_monitor.sh" ]; then
        "$SCRIPT_DIR/health_monitor.sh"
    else
        echo "health_monitor.sh not found or not executable."
        read -rp "Press Enter to continue..."
    fi
}

# Main Loop
while true; do
    show_menu
    case "$choice" in
        1) run_process_manager ;;
        2) run_disk_monitor ;;
        3) run_backup_manager ;;
        4) run_user_manager ;;
        5) run_health_monitor ;;
        6) echo "Goodbye Admin!"; exit 0 ;;
        *) echo "Invalid choice. Try again."; sleep 1 ;;
    esac
done
