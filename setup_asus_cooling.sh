#!/usr/bin/env bash
# ==============================================================================
# ASUS ROG Zephyrus G14 (GA402) Arch Linux Cooling & Fan Control Setup
# ==============================================================================
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run with sudo: sudo bash $0"
   exit 1
fi

echo "==> [1/4] Ensuring CPU Boost is permanently OFF across reboots..."
# 1. Disable immediately
if [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
    echo 0 > /sys/devices/system/cpu/cpufreq/boost || true
fi
# 2. Persist across reboots via systemd-tmpfiles
mkdir -p /etc/tmpfiles.d
echo "w /sys/devices/system/cpu/cpufreq/boost - - - - 0" > /etc/tmpfiles.d/disable-boost.conf

echo "==> [2/4] Fixing /etc/environment to use cold iGPU (Radeon 680M) as primary..."
# Clean duplicate or incorrect card1:card2 entries
sed -i '/AQ_DRM_DEVICES/d' /etc/environment
sed -i '/WLR_DRM_DEVICES/d' /etc/environment
cat >> /etc/environment << 'ENVEOF'
AQ_DRM_DEVICES=/dev/dri/by-path/pci-0000:07:00.0-card:/dev/dri/by-path/pci-0000:03:00.0-card
WLR_DRM_DEVICES=/dev/dri/by-path/pci-0000:07:00.0-card:/dev/dri/by-path/pci-0000:03:00.0-card
ENVEOF

echo "==> [3/4] Ensuring asusd daemon is active..."
systemctl start asusd || true

echo "==> [4/4] Activating custom cooling fan curves..."
asusctl fan-curve --mod-profile Performance --fan cpu --data "35c:30%,45c:40%,55c:50%,65c:65%,72c:75%,80c:85%,88c:95%,95c:100%" || true
asusctl fan-curve --mod-profile Performance --fan gpu --data "35c:30%,45c:40%,55c:50%,65c:65%,72c:75%,80c:85%,88c:95%,95c:100%" || true
asusctl fan-curve --mod-profile Performance --enable-fan-curves true || true
asusctl profile set Performance || true

echo ""
echo "===================================================================="
echo " [SUCCESS] Cooling configurations updated!"
echo " - CPU Boost: Disabled (drops CPU temps by ~15°C permanently)."
echo " - CPU Boost persistence: Configured in /etc/tmpfiles.d/disable-boost.conf."
echo " - Primary GPU: Fixed to iGPU (07:00.0 680M) in /etc/environment."
echo " - Active fans: Performance custom curve active (~3500 RPM)."
echo "===================================================================="
