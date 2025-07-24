#!/bin/bash

# The setup script for Raspberry Pi OS (Bookworm)

set -e

echo -e "\n[*] Updating package list...\n"
sudo apt update

echo -e "\n[*] Full system update...\n"
sudo apt full-upgrade -y

echo -e "\n[*] Installing WiFi/Bluetooth attack tools and dependencies...\n"
sudo apt install build-essential bluez libbluetooth-dev sox nmap aircrack-ng network-manager reaver bluez mdk3 -y

echo -e "\n[*] Building the carwhisperer exploit...\n"
cd "$(dirname "$0")/carwhisperer"
make

echo -e "\n[*] Installing tailscale...\n"
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

echo -e "\n[*] All dependencies installed and carwhisperer built.\n"

# This makes the connection between the raspberry pi and a phone more stable
echo -e "\n[*] Disabling wlan0 power management...\n"

cat <<EOF | sudo tee "/etc/NetworkManager/conf.d/disable-wifi-powersave.conf" > /dev/null 
[connection]
wifi.powersave = 2
EOF

read -p "Which wlan device will you be using? (eg. wlan1): " interface
read -p "Which hci device will you be using? (eg. hci0): " bt_interface

echo -e "export INTERFACE=${interface}" >> ~/.bashrc
echo -e "export INTERFACE_BT=${bt_interface}" >> ~/.bashrc

source ~/.bashrc

echo -e "\n[*] Restarting NetowkrManager... This will temporarily disconnect the raspberry pi from your hotspot\n"
sudo systemctl restart NetworkManager

echo "[*] Setup completed, scripts ready for use."
