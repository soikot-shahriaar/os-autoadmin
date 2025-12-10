# OS-AutoAdmin

A comprehensive Linux system administration automation suite designed to simplify common administrative tasks through an intuitive menu-driven interface.

## Features

OS-AutoAdmin provides five core management modules:

- **Process Manager** - Monitor and manage system processes
- **Disk Monitor** - Track disk usage with configurable thresholds
- **Backup Manager** - Create, manage, and restore compressed backups
- **User Manager** - Manage system users and permissions
- **Health Monitor** - Monitor system health metrics (CPU, memory, load)

## Project Structure

```
os-autoadmin/
├── scripts/           # Main executable scripts
│   ├── os_autoadmin.sh    # Main menu interface
│   ├── backup_manager.sh  # Backup management
│   ├── disk_monitor.sh    # Disk monitoring
│   ├── health_monitor.sh  # System health monitoring
│   ├── process_manager.sh # Process management
│   └── user_manager.sh    # User management
├── config/            # Configuration files
│   └── osl.conf          # Global configuration
├── logs/              # Log files directory
├── backups/           # Backup storage directory
└── README.md         # This file
```

## Installation

1. Clone or download the project to your home directory:
   ```bash
   cd ~
   git clone https://github.com/soikot-shahriaar/os-autoadmin.git
   # or extract downloaded archive to ~/os-autoadmin
   ```

2. Make scripts executable:
   ```bash
   chmod +x ~/os-autoadmin/scripts/*.sh
   ```

3. Run the main application:
   ```bash
   ~/os-autoadmin/scripts/os_autoadmin.sh
   ```

## Configuration

The system uses a central configuration file at `~/os-autoadmin/config/osl.conf`. You can customize:

- **Directories**: Log and backup storage locations
- **Thresholds**: Disk usage, memory usage, and CPU load alerts
- **User Settings**: Default groups and home directories for new users

## Usage

Launch the main menu:
```bash
./scripts/os_autoadmin.sh
```

Navigate through the menu options to access different management tools. Each module provides its own interactive interface with clear instructions.

## Requirements

- Linux operating system
- Bash shell
- Standard Unix tools (tar, grep, awk, etc.)
- Root/sudo privileges for certain operations

## Logging

All operations are logged to timestamped files in the `logs/` directory for auditing and troubleshooting.

## Contributing

Contributions are welcome! Please ensure scripts follow the established patterns and include appropriate error handling and logging.
