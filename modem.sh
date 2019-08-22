#!/bin/bash

set -e 

SECTION="Setting up Modem"
sudo usermod -aG dialout,dip "${USER}"
echo 'ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="a31d", ATTR{bConfigurationValue}:="3"' | sudo tee /etc/udev/rules.d/99-lt4132.modem.rules

cat <<'EOF' | sudo tee /lib/systemd/system-sleep/modem
#!/usr/bin/env bash
if [[ "$1" == "post" ]]; then
  echo 3 >/sys/bus/usb/devices/1-3/bConfigurationValue
fi
EOF
sudo chmod +x /lib/systemd/system-sleep/modem

if ! nmcli connection show | grep -Eq "^A1 "; then
  nmcli connection add ifname ttyUSB0 type gsm autoconnect false con-name A1 gsm.apn a1.net gsm.number *99# gsm.password ppp gsm.username ppp@a1plus.at ipv6.method ignore
  read -rp "Press ENTER to restart... "
  sudo reboot
fi
if nmcli connection show | grep -Eq "^A1 .*--"; then
  nmcli connection up A1
fi

