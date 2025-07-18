#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep "Mode:" | awk '{print $1}')

if [ ${mode} = "Mode:Managed" ]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode monitor
        sudo ifconfig ${INTERFACE} up
fi

read -p "ssid?: " ssid
read -p "count?: " count

AP_FILE="/home/pi/aps.txt"

rm -f "$AP_FILE"

echo "Creating list of APs..."
for i in $(seq 1 "$count"); do
  echo "$ssid$i" >> "$AP_FILE"
	
done

sudo mdk3 "$INTERFACE" b -f "$AP_FILE" -h
