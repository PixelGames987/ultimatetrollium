#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep "Mode:" | awk '{print $4}')

if [ ${mode} = "Mode:Managed" ]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode monitor
        sudo ifconfig ${INTERFACE} up
fi

read -p "bssid?: " bssid

read -p "channel?: " channel

rm -f "$HOME/captured/cap.cap-01.cap"

sudo iwconfig "$INTERFACE" channel "$channel"

sleep 3

sudo airodump-ng --bssid "$bssid" -c "$channel" -w "$HOME/captured/cap.cap" "$INTERFACE"

aircrack-ng "$HOME/captured/cap.cap-01.cap"
