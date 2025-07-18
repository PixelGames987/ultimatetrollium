#!/bin/bash

# The setup script for Raspberry Pi OS (Bookworm)

set -e

echo "[*] Updating package list..."
sudo apt update

echo "[*] Full system update..."
sudo apt full-upgrade -y

echo "[*] Installing WiFi/Bluetooth attack tools and dependencies..."
sudo apt install build-essential bluez libbluetooth-dev sox nmap aircrack-ng network-manager reaver bluez -y

echo "[*] Building the carwhisperer exploit..."
cd "$(dirname "$0")/carwhisperer"
make

echo "[*] All dependencies installed and carwhisperer built."
