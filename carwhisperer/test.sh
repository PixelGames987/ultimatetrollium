#!/bin/bash

while true ; do
	sudo ./carwhisperer hci0 message.raw out.raw B8:D5:0B:E6:8D:70 
done
