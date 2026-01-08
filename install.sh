#!/bin/bash
#
# Bambu LAN Discovery - Installer
# https://github.com/JRGgernaut/bambu-lan-discover
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/bambu-discover"
SYSTEMD_DIR="$HOME/.config/systemd/user"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     Bambu LAN Discovery - Installer                       ║"
echo "║     Make LAN-only printers appear in Bambu Studio         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create directories
echo -e "${GREEN}Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$SYSTEMD_DIR"

# Install main script
echo -e "${GREEN}Installing bambu-discover...${NC}"
cp "$SCRIPT_DIR/bambu-discover" "$INSTALL_DIR/bambu-discover"
chmod +x "$INSTALL_DIR/bambu-discover"

# Install systemd service
echo -e "${GREEN}Installing systemd service...${NC}"
cat > "$SYSTEMD_DIR/bambu-discover.service" << EOF
[Unit]
Description=Bambu Printer LAN Discovery Service
Documentation=https://github.com/JRGgernaut/bambu-lan-discover
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/bambu-discover --daemon
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Reload systemd
echo -e "${GREEN}Reloading systemd...${NC}"
systemctl --user daemon-reload

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Initialize your config with your printer details:"
echo ""
echo -e "   ${BLUE}bambu-discover --init --ip YOUR_PRINTER_IP --serial YOUR_SERIAL --model P1S${NC}"
echo ""
echo "   Or edit the config directly:"
echo -e "   ${BLUE}nano ~/.config/bambu-discover/config.json${NC}"
echo ""
echo "2. Test it (with Bambu Studio open):"
echo ""
echo -e "   ${BLUE}bambu-discover --once${NC}"
echo ""
echo "3. Enable automatic startup:"
echo ""
echo -e "   ${BLUE}systemctl --user enable --now bambu-discover${NC}"
echo ""
echo "Supported models: X1C, X1, X1E, P1P, P1S, P2S, A1, A1-Mini, H2D"
echo ""
