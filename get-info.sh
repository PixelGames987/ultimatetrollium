#!/bin/bash

if iwconfig "${INTERFACE}" | grep -q "ESSID:off/any"; then
	echo "Connect to a network first"
	exit 1
fi

ip_cidr=$(ip a show "${INTERFACE}" | grep -Eo 'inet ([0-9]*\.){3}[0-9]*/[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*/[0-9]*' | head -n 1)

nmap -p- -T4 "${ip_cidr}" -v
