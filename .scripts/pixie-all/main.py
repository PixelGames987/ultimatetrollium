#!venv/bin/python

import nmcli
import os

INTERFACE = os.getenv("INTERFACE")

def scan(interface: str, rescan: bool=True):
    nmcli.device.wifi_rescan(ifname=interface)
    return nmcli.device.wifi(ifname=interface, rescan=rescan)


def main_loop():
    networks = scan(INTERFACE, True)

    print(f"Networks found:\n")
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


    


if __name__ == "__main__":
    main_loop()
