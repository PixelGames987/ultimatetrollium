#!/bin/bash

exec_path="carwhisperer"
message_file="message.raw"
output_raw="out.raw"
output_wav="out.wav"

read -p "scan mode? (1: BR/EDR | 2: BLE | 3: ALL): " scan_mode

sudo systemctl restart bluetooth # Restarts the bluetooth service to avoid hcitool errors
sleep 2

if [ ${scan_mode} = "1" ]; then
	sudo stdbuf -oL hcitool -i "$INTERFACE_BT" scan

elif [ ${scan_mode} = "2" ]; then
	echo "Press ctrl+c to stop scan"
	sudo stdbuf -oL hcitool -i "$INTERFACE_BT" lescan

elif [ ${scan_mode} = "3" ]; then
	sudo stdbuf -oL hcitool -i "$INTERFACE_BT" scan
        timeout 10 sudo stdbuf -oL hcitool -i "$INTERFACE_BT"
else
	echo "Enter a valid mode"
	exit 1
fi

read -p "bssid?: " bssid


rm -f "$output_raw"

$exec_path hci0 "$message_file" "$output_raw" "$bssid"

sudo sox -t raw -r 8000 -c 1 -e signed-integer -b 16 --endian little "$output_raw" "$output_wav"

echo "File saved to $output_wav"
