#!/bin/bash

# OS-AutoAdmin: User Manager

# Find project root based on script location
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/osl.conf"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

LOG_FILE="$LOG_DIR/user_manager.log"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_menu() {
    clear
    echo "===== OS-AutoAdmin: User Manager ====="
    echo "1) List normal users"
    echo "2) Show logged-in users"
    echo "3) Add new user"
    echo "4) View last 20 log entries"
    echo "5) Exit"
    echo "======================================"
    read -rp "Enter your choice: " choice
}

list_normal_users() {
    echo
    echo "Normal (non-system) users:"
    echo "--------------------------------------"
    # Show users with UID >= 1000 and != 65534 (nobody)
    awk -F: '$3 >= 1000 && $3 != 65534 {printf "%-20s UID=%s\n", $1, $3}' /etc/passwd
    log "Listed normal users"
    echo
    read -rp "Press Enter to continue..."
}

show_logged_in_users() {
    echo
    echo "Currently logged-in users:"
    echo "---------------------------"
    who
    log "Displayed logged-in users"
    echo
    read -rp "Press Enter to continue..."
}

add_new_user() {
    echo
    echo "Add new user"
    echo "------------"

    read -rp "Enter new username: " username
    if [ -z "$username" ]; then
        echo "Username cannot be empty."
        log "Add user failed: empty username"
        read -rp "Press Enter to continue..."
        return
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."
        log "Add user failed: $username already exists"
        read -rp "Press Enter to continue..."
        return
    fi

    read -rp "Enter full name (optional): " fullname

    echo
    echo "Creating user '$username'..."
    # Use sudo only for the commands that need root
    if sudo useradd -m -c "$fullname" "$username"; then
        echo "User '$username' created successfully."
        log "Created user $username"
        echo
        echo "Now set password for '$username':"
        sudo passwd "$username"
        log "Password set for user $username"
    else
        echo "Failed to create user '$username'."
        log "Failed to create user $username"
    fi

    echo
    read -rp "Press Enter to continue..."
}

view_logs() {
    echo
    echo "Last 20 log entries from $LOG_FILE:"
    echo "--------------------------------------"
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
        1) list_normal_users ;;
        2) show_logged_in_users ;;
        3) add_new_user ;;
        4) view_logs ;;
        5) echo "Exiting User Manager."; exit 0 ;;
        *) echo "Invalid choice. Try again."; sleep 1 ;;
    esac
done
