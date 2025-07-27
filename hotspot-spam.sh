#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep -o "Mode:Managed")

if [ "${mode}" = "Mode:Managed" ]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode monitor
        sudo ifconfig ${INTERFACE} up
fi

read -p "ssid?: " ssid
read -p "count?: " count

AP_FILE="/tmp/aps.txt"

rm -f "$AP_FILE"

echo "Creating list of APs..."
for i in $(seq 1 "$count"); do
  echo "$ssid$i" >> "$AP_FILE"
	
done

sudo mdk3 "$INTERFACE" b -f "$AP_FILE" -h
