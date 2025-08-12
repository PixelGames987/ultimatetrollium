#!/bin/bash

if ! command -v tailscale &> /dev/null; then
	echo "Tailscale not found, install it from the tailscale.com website"
	exit 1
fi

network_name=$(iwconfig "${INTERFACE}">/dev/null | grep ESSID | awk '{print $4}' | cut -d':' -f2)

if iwconfig "${INTERFACE}" | grep -q "ESSID:off/any"; then
        echo "Connect to a network first"
        exit 1
fi

read -p "Enter the route to use (192.168.1.0/24): " route
sudo tailscale up --advertise-exit-node --advertise-routes $route
