#!/bin/bash

# OS-AutoAdmin: Health Monitor

CONFIG_FILE="$HOME/os-autoadmin/config/osl.conf"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

LOG_FILE="$LOG_DIR/health_monitor.log"
mkdir -p "$LOG_DIR"

# Default if not set
HEALTH_REPORT="${HEALTH_REPORT:-$LOG_DIR/system_health_report.log}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_menu() {
    clear
    echo "===== OS-AutoAdmin: Health Monitor ====="
    echo "1) Generate health report"
    echo "2) View latest health report"
    echo "3) View last 20 log entries"
    echo "4) Exit"
    echo "========================================"
    read -rp "Enter your choice: " choice
}

get_cpu_load_status() {
    # 1-minute load average from /proc/loadavg
    load_1=$(awk '{print $1}' /proc/loadavg)

    status="OK"

    greater_equal() {
        awk -v n1="$1" -v n2="$2" 'BEGIN { if (n1+0 >= n2+0) exit 0; else exit 1 }'
    }

    if greater_equal "$load_1" "$CPU_LOAD_CRIT"; then
        status="CRITICAL"
    elif greater_equal "$load_1" "$CPU_LOAD_WARN"; then
        status="WARNING"
    fi

    echo "$load_1|$status"
}

get_mem_status() {
    # Use 'free' to calculate used percentage
    read -r total used free <<< "$(free -m | awk 'NR==2 {print $2, $3, $4}')"
    used_percent=$(( used * 100 / total ))

    status="OK"
    if [ "$used_percent" -ge "$MEM_CRIT" ]; then
        status="CRITICAL"
    elif [ "$used_percent" -ge "$MEM_WARN" ]; then
        status="WARNING"
    fi

    echo "$used_percent|$status|$total|$used|$free"
}

generate_report() {
    log "Generating health report"

    echo "Generating system health report..."
    echo

    {
        echo "========================================"
        echo " OS-AutoAdmin: System Health Report"
        echo " Generated at: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "========================================"
        echo

        # CPU Section
        cpu_info=$(get_cpu_load_status)
        cpu_load=$(echo "$cpu_info" | cut -d'|' -f1)
        cpu_status=$(echo "$cpu_info" | cut -d'|' -f2)

        echo "[CPU]"
        echo "1-min Load Average : $cpu_load"
        echo "Status             : $cpu_status"
        echo

        # Memory Section
        mem_info=$(get_mem_status)
        mem_used_percent=$(echo "$mem_info" | cut -d'|' -f1)
        mem_status=$(echo "$mem_info" | cut -d'|' -f2)
        mem_total=$(echo "$mem_info" | cut -d'|' -f3)
        mem_used=$(echo "$mem_info" | cut -d'|' -f4)
        mem_free=$(echo "$mem_info" | cut -d'|' -f5)

        echo "[Memory]"
        echo "Total (MB)         : $mem_total"
        echo "Used (MB)          : $mem_used"
        echo "Free (MB)          : $mem_free"
        echo "Usage              : ${mem_used_percent}%"
        echo "Status             : $mem_status"
        echo

        # Disk Section (summary)
        echo "[Disk Usage] (df -h)"
        df -h
        echo

        # Top processes by CPU
        echo "[Top 5 Processes by CPU]"
        ps aux --sort=-%cpu | head -n 6
        echo

        # Top processes by Memory
        echo "[Top 5 Processes by Memory]"
        ps aux --sort=-%mem | head -n 6
        echo

    } > "$HEALTH_REPORT"

    echo "Health report generated at:"
    echo "   $HEALTH_REPORT"
    log "Health report generated at $HEALTH_REPORT"

    read -rp "Press Enter to continue..."
}

view_report() {
    echo
    echo "Showing latest health report:"
    echo "-----------------------------"
    if [ -f "$HEALTH_REPORT" ]; then
        less "$HEALTH_REPORT"
        log "Viewed health report"
    else
        echo "No health report found. Generate one first."
        log "Health report view attempted but file missing"
        echo
        read -rp "Press Enter to continue..."
    fi
}

view_logs() {
    echo
    echo "Last 20 log entries from $LOG_FILE:"
    echo "------------------------------------"
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
        1) generate_report ;;
        2) view_report ;;
        3) view_logs ;;
        4) echo "Exiting Health Monitor."; exit 0 ;;
        *) echo "Invalid choice. Try again."; sleep 1 ;;
    esac
done
