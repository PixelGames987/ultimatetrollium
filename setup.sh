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
cd ..
mkdir -p "$(dirname "$0")/carwhisperer/output"

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

echo -e "\n[*] Installing kismet...\n"

wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo "deb https://www.kismetwireless.net/repos/apt/release/$(lsb_release -cs) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet -y
sudo systemctl disable kismet

echo -e "\n[*] Setting up wifijammer.py\n"

python -m venv .scripts/wifijammer/.venv
.scripts/wifijammer/.venv/bin/python -m pip install scapy==2.4.3

cd /usr/lib/aarch64-linux-gnu
sudo ln -s -f libc.a liblibc.a
cd -

echo -e "\n[*] wifijammer.py ready to use\n"

read -p "Which wlan device will you be using? (eg. wlan1): " interface
read -p "Which hci device will you be using? (eg. hci0): " bt_interface
sudo iwconfig
read -p "Copy and paste your hotspot's mac address/bssid: " mac

echo -e "export INTERFACE=${interface}" >> ~/.bashrc
echo -e "export INTERFACE_BT=${bt_interface}" >> ~/.bashrc
echo -e "export MAC=\"${mac}\"" >> ~/.bashrc

source ~/.bashrc

sudo sh -c "echo \"source=${INTERFACE}\" >> /etc/kismet/kismet.conf"

echo -e "\n[*] Restarting NetowkrManager... This will temporarily disconnect the raspberry pi from your hotspot\n"
sudo systemctl restart NetworkManager

echo "[*] Setup completed, scripts ready for use."
