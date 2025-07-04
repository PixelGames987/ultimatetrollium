#!/bin/bash

message_file="message.raw"

read -p "wav file name?: " file

rm -f "$message_file"

sox -t wav -r 44100 -c 2 "$file" -t raw -r 8000 -c 1 -e signed-integer -b 16 "$message_file"
