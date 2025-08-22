# ultimatetrollium
A collection of simple bash scripts for the raspberry pi made to simplify running wifi/bluetooth attacks using ssh.

Note: Some scripts were not made by me. 

Carwhisperer: https://trifinite.org/stuff/carwhisperer

wifijammer: https://github.com/hash3liZer/wifijammer

OneShot-Extended: https://github.com/chickendrop89/OneShot-Extended

How to setup?
```
sudo apt update
sudo apt install git -y

git clone https://github.com/PixelGames987/ultimatetrollium/
cd ultimatetrollium

./setup.sh
```

The setup script installs:
```
build-essential, bluez, libbluetooth-dev, sox, nmap, aircrack-ng, network-manager, reaver, bluez, mdk3
carwhisperer
tailscale (optional)
kismet
wifijammer
```
