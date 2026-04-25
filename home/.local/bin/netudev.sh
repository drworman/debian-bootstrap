#!/bin/bash
# netudev.sh — generate udev rules pinning network interface names
#
# Usage:
#   sudo netudev.sh
#
# Scans /sys/class/net for the first non-loopback ethernet and the first
# wireless interface, then writes a udev rules file that renames them to
# `eth0` and `wlan0` based on their MAC addresses. Reloads udev rules
# afterwards. A reboot is required for the new names to take effect.
#
# Useful when systemd's predictable interface names (enp0s31f6, wlp3s0…)
# are causing problems with scripts that expect classic names.
#
# Dependencies: udev (udevadm), coreutils, sudo
#
# ─── User-editable variables ────────────────────────────────────────────────
# Where the generated rules file is written. udev reads anything under
# /etc/udev/rules.d/ named *.rules.
RULES_FILE="/etc/udev/rules.d/10-network.rules"
# ─── Do not edit below this line ────────────────────────────────────────────

set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo "🔍 Scanning available network interfaces..."

eth_iface=""
wifi_iface=""

for iface_path in /sys/class/net/*; do
    iface=$(basename "$iface_path")
    [[ "$iface" == "lo" ]] && continue

    if [[ -d "$iface_path/wireless" ]]; then
        [[ -z "$wifi_iface" ]] && wifi_iface="$iface"
    else
        [[ -z "$eth_iface" ]] && eth_iface="$iface"
    fi
done

eth_mac=""
wifi_mac=""

[[ -n "$eth_iface" ]] && eth_mac=$(cat "/sys/class/net/$eth_iface/address")
[[ -n "$wifi_iface" ]] && wifi_mac=$(cat "/sys/class/net/$wifi_iface/address")

if [[ -n "$eth_mac" || -n "$wifi_mac" ]]; then
    echo "✔ Detected devices:"
    [[ -n "$eth_mac" ]] && echo "  - Ethernet: $eth_iface ($eth_mac)"
    [[ -n "$wifi_mac" ]] && echo "  - Wi-Fi:    $wifi_iface ($wifi_mac)"

    echo "📝 Writing udev rules to $RULES_FILE..."

    RULES_CONTENT="# Auto-generated udev rules to rename network interfaces"
    [[ -n "$eth_mac" ]] && RULES_CONTENT+="
SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$eth_mac\", NAME=\"eth0\""
    [[ -n "$wifi_mac" ]] && RULES_CONTENT+="
SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$wifi_mac\", NAME=\"wlan0\""

    echo "$RULES_CONTENT" | $SUDO tee "$RULES_FILE" > /dev/null

    $SUDO udevadm control --reload
    $SUDO udevadm trigger

    echo "✅ Done. Reboot to apply new interface names."
else
    echo "⚠️ No Ethernet or Wi-Fi interfaces detected. No rules written."
fi
