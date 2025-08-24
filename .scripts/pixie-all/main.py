#!venv/bin/python

import nmcli
import os

INTERFACE = os.getenv("INTERFACE")

def scan(interface: str, rescan: bool=True):
    nmcli.device.wifi_rescan(ifname=interface)
    return nmcli.device.wifi(ifname=interface, rescan=rescan)


def main_loop():
    pass


if __name__ == "__main__":
    main_loop()
