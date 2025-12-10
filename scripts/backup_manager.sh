#!/bin/bash

# OS-AutoAdmin: Backup Manager

CONFIG_FILE="$HOME/os-autoadmin/config/osl.conf"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

LOG_FILE="$LOG_DIR/backup_manager.log"
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_menu() {
    clear
    echo "===== OS-AutoAdmin: Backup Manager ====="
    echo "1) Backup a directory now"
    echo "2) List existing backups"
    echo "3) View contents of a backup (tar -tzf)"
    echo "4) Delete a backup"
    echo "5) Exit"
    echo "========================================"
    read -rp "Enter your choice: " choice
}

backup_directory() {
    echo
    read -rp "Enter full path of directory to backup: " src_dir

    if [ ! -d "$src_dir" ]; then
        echo "Directory does not exist: $src_dir"
        log "Backup failed: directory not found ($src_dir)"
        read -rp "Press Enter to continue..."
        return
    fi

    # Get clean name from the directory (basename)
    dir_name=$(basename "$src_dir")
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_file="${BACKUP_DIR}/${dir_name}_backup_${timestamp}.tar.gz"

    echo "Creating backup..."
    echo "Source : $src_dir"
    echo "Target : $backup_file"
    echo

    # Create compressed tar archive
    if tar -czf "$backup_file" -C "$(dirname "$src_dir")" "$dir_name"; then
        echo " Backup completed successfully."
        log "Backup created: $backup_file from $src_dir"
    else
        echo " Backup failed."
        log "Backup FAILED for: $src_dir"
        # Remove partially created file if tar failed
        [ -f "$backup_file" ] && rm -f "$backup_file"
    fi

    echo
    read -rp "Press Enter to continue..."
}

list_backups() {
    echo
    echo "Backups in $BACKUP_DIR:"
    echo "----------------------------"

    if ls "$BACKUP_DIR"/*.tar.gz >/dev/null 2>&1; then
        ls -lh "$BACKUP_DIR"/*.tar.gz
    else
        echo "No backups found."
    fi

    log "Listed existing backups"
    echo
    read -rp "Press Enter to continue..."
}

view_backup_contents() {
    echo
    echo "Available backups:"
    if ! ls "$BACKUP_DIR"/*.tar.gz >/dev/null 2>&1; then
        echo "No backups to inspect."
        read -rp "Press Enter to continue..."
        return
    fi

    ls -1 "$BACKUP_DIR"/*.tar.gz
    echo
    read -rp "Enter full path of backup file to view: " backup_file

    if [ ! -f "$backup_file" ]; then
        echo "File not found: $backup_file"
        log "View contents failed: file not found ($backup_file)"
        read -rp "Press Enter to continue..."
        return
    fi

    echo
    echo "Contents of $backup_file:"
    echo "---------------------------------"
    tar -tzf "$backup_file" | head -n 50
    echo "..."
    echo "(Showing first 50 entries only)"
    log "Viewed contents of backup: $backup_file"

    echo
    read -rp "Press Enter to continue..."
}

delete_backup() {
    echo
    echo "Available backups:"
    if ! ls "$BACKUP_DIR"/*.tar.gz >/dev/null 2>&1; then
        echo "No backups to delete."
        read -rp "Press Enter to continue..."
        return
    fi

    ls -1 "$BACKUP_DIR"/*.tar.gz
    echo
    read -rp "Enter full path of backup file to delete: " backup_file

    if [ ! -f "$backup_file" ]; then
        echo "File not found: $backup_file"
        log "Delete failed: file not found ($backup_file)"
        read -rp "Press Enter to continue..."
        return
    fi

    read -rp "Are you sure you want to delete $backup_file? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        if rm -f "$backup_file"; then
            echo "Backup deleted."
            log "Deleted backup: $backup_file"
        else
            echo "Failed to delete backup."
            log "Delete FAILED for backup: $backup_file"
        fi
    else
        echo "Operation cancelled."
        log "User cancelled delete for: $backup_file"
    fi

    echo
    read -rp "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    case "$choice" in
        1) backup_directory ;;
        2) list_backups ;;
        3) view_backup_contents ;;
        4) delete_backup ;;
        5) echo "Exiting Backup Manager."; exit 0 ;;
        *) echo "Invalid choice. Try again."; sleep 1 ;;
    esac
done
