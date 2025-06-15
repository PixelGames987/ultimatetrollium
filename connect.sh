#!/bin/bash

read -p "ssid?: " ssid

read -s -p "password?: " password
echo

sudo nmcli dev wifi connect "$ssid" password "$password" ifname "$INTERFACE"

if [ $? -eq 0 ]; then
  echo "Successfully connected to $ssid."
else
  echo "Connection to $ssid failed."
  exit 1
fi

exit 0
