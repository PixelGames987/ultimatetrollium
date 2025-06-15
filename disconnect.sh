#!/bin/bash

read -p "ssid?: " connection

sudo nmcli con down "$connection"

if [ $? -eq 0 ]; then
  echo "Disconnected from $connection."
else
  echo "Failed to disconnect from $connection."
  exit 1
fi

sudo nmcli con delete "$connection"

if [ $? -eq 0 ]; then
  echo "Deleted connection $connection."
else
  echo "Failed to delete connection $connection."
  exit 1
fi

exit 0
