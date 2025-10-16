import argparse
import sys
import os
from scapy.all import *
from mac_vendor_lookup import MacLookup

# A set to keep track of probe requests
probed_networks = set()

mac_lookup = None
try:
    mac_lookup = MacLookup()
    mac_lookup.update_vendors()
except Exception as e:
    print(f"[!] Could not initialize or update MAC vendor database: {e}")

def check_root():
    if os.geteuid() != 0:
        print("[-] This script requires root privileges.")
        sys.exit(1)

def packet_handler(packet, mac_filter=None):
    if packet.haslayer(Dot11ProbeReq):
        # Extract source MAC address
        client_mac = packet.addr2

        # Apply a MAC filter
        if mac_filter and client_mac.lower() != mac_filter.lower():
            return

        # SSID information
        if packet.haslayer(Dot11Elt):
            try:
                essid = packet[Dot11Elt].info.decode()
                if not essid:
                    essid = "(Hidden)"
            except UnicodeDecodeError:
                essid = packet[Dot11Elt].info

            # Create a key for a set to avoid duplicates
            probe_key = (client_mac, essid)

            if probe_key not in probed_networks:
                probed_networks.add(probe_key)
                
                vendor = "Unknown Vendor"
                if mac_lookup:
                    try:
                        vendor = mac_lookup.lookup(client_mac)
                    except KeyError:
                        pass

                # Print in a spreadsheet-like format
                print(f"{client_mac:<20} {vendor:<45} {essid}")


def main():
    check_root()

    parser = argparse.ArgumentParser(
        description="Wi-Fi Probe Scanner.",
        formatter_class=argparse.RawTextHelpFormatter # For better help formatting
    )
    parser.add_argument("-i", "--interface", required=True, help="The wireless interface to use (must be in monitor mode).")
    parser.add_argument("-m", "--mac-filter", help="Filter output to a specific client MAC address.")
    
    args = parser.parse_args()
    interface = args.interface
    mac_filter = args.mac_filter

    print(f"[*] Starting probe scanner on interface {interface}...")
    if mac_filter:
        print(f"[*] Filtering for client MAC: {mac_filter}")
    print("[*] Press CTRL+C to stop.\n")

    # Print in a spreadsheet-like format
    print(f"{'Client MAC':<20} {'Vendor':<45} {'Target ESSID'}")
    print(f"{'='*19:<20} {'='*44:<45} {'='*20}")

    try:
        # Start sniffing.
        sniff(iface=interface, prn=lambda pkt: packet_handler(pkt, mac_filter), store=0)
    except KeyboardInterrupt:
        print("\n[*] Stopping scanner.")
    except Exception as e:
        print(f"\n[!] An error occurred: {e}")
        print("[!] Ensure the interface is in monitor mode.")
        
if __name__ == "__main__":
    main()
