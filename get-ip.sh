#!/bin/bash

if iwconfig "${INTERFACE}" | grep -q "ESSID:off/any"; then
        echo "Connect to a network first"
        exit 1
fi

curl --interface ${INTERFACE} ipinfo.io
echo -e "\n"
curl --interface ${INTERFACE} ifconfig.xyz
