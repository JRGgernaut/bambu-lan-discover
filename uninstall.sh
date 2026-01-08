#!/bin/bash
#
# Bambu LAN Discovery - Uninstaller
#

set -e

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/bambu-discover"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "Bambu LAN Discovery - Uninstaller"
echo "=================================="
echo ""

# Stop and disable service
echo "Stopping service..."
systemctl --user stop bambu-discover 2>/dev/null || true
systemctl --user disable bambu-discover 2>/dev/null || true

# Remove files
echo "Removing files..."
rm -f "$INSTALL_DIR/bambu-discover"
rm -f "$SYSTEMD_DIR/bambu-discover.service"

# Ask about config
read -p "Remove configuration? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    echo "Configuration removed."
else
    echo "Configuration kept at $CONFIG_DIR"
fi

# Reload systemd
systemctl --user daemon-reload

echo ""
echo "Uninstall complete!"
