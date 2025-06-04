#!/bin/bash

network_name=$(iwconfig "${INTERFACE}">/dev/null | grep ESSID | awk '{print $4}' | cut -d':' -f2)

if iwconfig "${INTERFACE}" | grep -q "ESSID:off/any"; then
	echo "Connect to a network first"
	exit 1
fi

ip a

nmap -p- -T4 $(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1') -v
