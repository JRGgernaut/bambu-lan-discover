# Bambu LAN Discovery

**Make LAN-only Bambu Lab printers appear in Bambu Studio without cloud connectivity.**

Bambu Studio relies on SSDP multicast for printer discovery, which fails in many network configurations (VLANs, VPNs, enterprise networks, or when the printer simply doesn't broadcast). This tool sends fake SSDP discovery packets to make your printer appear in Bambu Studio automatically.

## The Problem

When using Bambu Lab printers in **LAN Only Mode**, Bambu Studio frequently:
- Fails to discover the printer
- "Forgets" the printer after restart
- Requires re-entering the access code every time

This is a [known issue](https://github.com/bambulab/BambuStudio/issues/702) with no official fix.

## The Solution

This tool sends SSDP discovery packets directly to Bambu Studio's listening port (UDP 2021), making it think it discovered your printer on the network.

## Supported Printers

| Model | Code |
|-------|------|
| X1 Carbon | X1C |
| X1 | X1 |
| X1E | X1E |
| P1P | P1P |
| P1S | P1S |
| P2S | P2S |
| A1 | A1 |
| A1 Mini | A1-Mini |
| H2D | H2D |
| H2D Pro | H2D-Pro |
| H2S | H2S |
| H2C | H2C |

## Installation

### Quick Install (Arch Linux / Most Distros)

```bash
git clone https://github.com/JRGgernaut/bambu-lan-discover.git
cd bambu-lan-discover
./install.sh
```

### Manual Install

```bash
# Copy the script
cp bambu-discover ~/.local/bin/
chmod +x ~/.local/bin/bambu-discover

# Copy systemd service
cp bambu-discover.service ~/.config/systemd/user/
systemctl --user daemon-reload
```

## Configuration

### Quick Setup

```bash
bambu-discover --init --ip 192.168.1.100 --serial YOUR_SERIAL --model P1S --name "My Printer"
```

### Manual Configuration

Edit `~/.config/bambu-discover/config.json`:

```json
{
  "printers": [
    {
      "name": "My Bambu P1S",
      "ip": "192.168.1.100",
      "serial": "00M00A000000000",
      "model": "P1S"
    }
  ],
  "target_ip": "127.0.0.1",
  "target_port": 2021,
  "interval": 5
}
```

### Finding Your Printer Info

| Info | Where to Find It |
|------|------------------|
| **IP Address** | Printer screen → Settings → LAN Only Mode |
| **Serial Number** | Printer screen → Settings → Device and Serial Number |
| **Model** | On the printer itself |

## Usage

### Test Once

```bash
# Open Bambu Studio first, then:
bambu-discover --once
```

Your printer should appear in the Device tab within seconds.

### Run as Daemon

```bash
# Run in foreground
bambu-discover --daemon --verbose

# Or enable the systemd service for auto-start
systemctl --user enable --now bambu-discover
```

### Check Status

```bash
systemctl --user status bambu-discover
```

### View Logs

```bash
journalctl --user -u bambu-discover -f
```

## Command Line Options

```
Usage: bambu-discover [OPTIONS]

Options:
  --init              Create initial config file
  --daemon, -d        Run continuously in background
  --once, -1          Send discovery once and exit
  --verbose, -v       Print each discovery sent
  --config, -c PATH   Config file path

Quick setup:
  --ip IP             Printer IP address
  --serial SERIAL     Printer serial number
  --model MODEL       Printer model (X1C, P1S, A1, etc.)
  --name NAME         Printer display name
```

## Multiple Printers

Add multiple printers to your config:

```json
{
  "printers": [
    {
      "name": "Printer 1",
      "ip": "192.168.1.100",
      "serial": "SERIAL1",
      "model": "P1S"
    },
    {
      "name": "Printer 2",
      "ip": "192.168.1.101",
      "serial": "SERIAL2",
      "model": "X1C"
    }
  ],
  "target_ip": "127.0.0.1",
  "target_port": 2021,
  "interval": 5
}
```

## How It Works

Bambu Studio listens on UDP port 2021 for SSDP discovery responses. When a Bambu printer is on your network, it broadcasts packets like:

```
HTTP/1.1 200 OK
Server: Buildroot/2018.02-rc3 UPnP/1.0 ssdpd/1.8
Location: 192.168.1.100
ST: urn:bambulab-com:device:3dprinter:1
USN: 00M00A000000000
DevModel.bambu.com: C12
DevName.bambu.com: My Printer
DevConnect.bambu.com: lan
DevBind.bambu.com: free
```

This tool sends the same packets, making Bambu Studio think it discovered your printer.

## Troubleshooting

### Printer not appearing

1. Make sure Bambu Studio is running
2. Check the printer IP is correct: `ping YOUR_PRINTER_IP`
3. Run with verbose mode: `bambu-discover --daemon --verbose`
4. Check firewall isn't blocking UDP 2021

### Access code not saved

This is a separate Bambu Studio bug. The discovery tool only makes the printer appear - you may still need to enter the access code once. It should be saved after that.

### Service not starting

```bash
# Check for errors
journalctl --user -u bambu-discover -e

# Make sure config exists
cat ~/.config/bambu-discover/config.json
```

## Uninstall

```bash
./uninstall.sh
```

Or manually:

```bash
systemctl --user disable --now bambu-discover
rm ~/.local/bin/bambu-discover
rm ~/.config/systemd/user/bambu-discover.service
rm -rf ~/.config/bambu-discover
```

## Credits

Based on research and scripts from:
- [GitHub Issue #702](https://github.com/bambulab/BambuStudio/issues/702)
- [gashton/bambustudio_tools](https://github.com/gashton/bambustudio_tools)
- [SSDP Discovery Gist](https://gist.github.com/Alex-Schaefer/72a9e2491a42da2ef99fb87601955cc3)
- [bsnotify](https://github.com/jonans/bsnotify)

## License

MIT License - do whatever you want with it.
