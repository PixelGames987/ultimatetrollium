#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep "Mode:" | awk '{print $4}')

if [ ${mode} = "Mode:Monitor" ]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode managed
        sudo ifconfig ${INTERFACE} up
        echo "Re-run the script after network scan is complete"
	exit 0
fi

read -p "ssid?: " connection

sudo nmcli con down "$connection"

if [ $? -eq 0 ]; then
  echo "Disconnected from $connection."
else
  echo "Failed to disconnect from $connection."
  exit 1
fi

sudo nmcli con delete "$connection"

if [ $? -eq 0 ]; then
  echo "Deleted connection $connection."
else
  echo "Failed to delete connection $connection."
  exit 1
fi

exit 0
