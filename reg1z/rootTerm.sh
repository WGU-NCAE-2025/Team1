#!/bin/bash

# Script to open root terminal in configuration directory for logging system
# Usage: ./script.sh [journald|rsyslog]

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [journald|rsyslog]"
    exit 1
fi

# Check if user has sudo privileges
if ! sudo -v &>/dev/null; then
    echo "This script requires sudo privileges"
    exit 1
fi

# Determine target directory based on argument
case "$1" in
    "journald")
        TARGET_DIR="/etc/systemd/journald.conf.d"
        # Create directory if it doesn't exist (common for journald.conf.d)
        if [ ! -d "$TARGET_DIR" ]; then
            sudo mkdir -p "$TARGET_DIR"
            echo "Created $TARGET_DIR directory"
        fi
        ;;
    "rsyslog")
        TARGET_DIR="/etc/rsyslog.d"
        ;;
    *)
        echo "Invalid argument. Use 'journald' or 'rsyslog'"
        exit 1
        ;;
esac

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_DIR directory does not exist"
    exit 1
fi

# Detect terminal emulator
if command -v gnome-terminal &> /dev/null; then
    # GNOME Terminal (Ubuntu, Fedora, etc.)
    gnome-terminal -- sudo -E bash -c "cd \"$TARGET_DIR\" && exec bash"
elif command -v xterm &> /dev/null; then
    # xterm (widely available)
    xterm -e "sudo -E bash -c 'cd \"$TARGET_DIR\" && exec bash'"
elif command -v konsole &> /dev/null; then
    # KDE's Konsole
    konsole --new-tab -e sudo -E bash -c "cd \"$TARGET_DIR\" && exec bash"
elif command -v xfce4-terminal &> /dev/null; then
    # XFCE Terminal
    xfce4-terminal -e "sudo -E bash -c 'cd \"$TARGET_DIR\" && exec bash'"
elif command -v mate-terminal &> /dev/null; then
    # MATE Terminal
    mate-terminal -e "sudo -E bash -c 'cd \"$TARGET_DIR\" && exec bash'"
elif command -v tilix &> /dev/null; then
    # Tilix Terminal
    tilix -e "sudo -E bash -c 'cd \"$TARGET_DIR\" && exec bash'"
elif command -v terminator &> /dev/null; then
    # Terminator
    terminator -e "sudo -E bash -c 'cd \"$TARGET_DIR\" && exec bash'"
else
    echo "No supported terminal emulator found. Falling back to current terminal."
    sudo -E bash -c "cd \"$TARGET_DIR\" && exec bash"
fi

echo "Opening root terminal in $TARGET_DIR"
