#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep "Mode:" | awk '{print $4}')

if [ ${mode} = "Mode:Monitor" ]; then
	sudo ifconfig ${INTERFACE} down
	sudo iwconfig ${INTERFACE} mode managed
	sudo ifconfig ${INTERFACE} up
	echo "Re-run the script after network scan is complete"
fi

nmcli dev wifi list ifname ${INTERFACE} --rescan yes
