#!/bin/bash

set -e

echo 'Enter domain:' && read domain
echo 'Enter env:' && read environment

tpm2_clear
echo "### Creating primary"
tpm2_createprimary  -C o -c parent.ctx -G rsa2048:null:aes128cfb
echo "### Done primary"


echo "### Persisting primary"
tpm2_evictcontrol -c parent.ctx > primary.log
echo "### Done persist"
HANDLE=$(cat primary.log | grep "persistent-handle" | awk '{printf $2}')
cat primary.log
echo "HANDLE ${HANDLE##*x}"


tpm2_import  -i $1 -r private_key.tss -u public_key.tss -Grsa -C parent.ctx
tpm2_load  -C parent.ctx -u public_key.tss -r private_key.tss -c wzhpor.ctx
tpm2_evictcontrol -c wzhpor.ctx

npx @rpofuk/tpm2-asn-packer p ${HANDLE##*x} private_key.tss public_key.tss ewp401007.tss


nmcli connection import type openvpn file ewp401007.ovpn
nmcli connection modify ewp401007 ipv4.never-default yes
nmcli connection modify ewp401007 ipv4.dns-search "${domain}"
nmcli connection modify ewp401007 +vpn.data key=$(realpath ewp401007.tss)
nmcli connection modify ewp401007 +vpn.data cert=$(realpath ewp401007.crt)
nmcli connection modify ewp401007 ipv6.method ignore


sudo rm -f /etc/network/if-up.d/ewp
sudo echo '#!/bin/bash 

set -ex
touch /tmp/out.log
echo "Turning on ${IFACE}" 
if [[ "${IFACE}" == "tun0" && "${NM_DISPATCHER_ACTION}" == "vpn-up" ]]; then 
  echo "Handling ${IFACE}"
  
  url="https://ewp-login-web-'"$environment"'.'"${domain}"'"
  user="$(who | grep ":1" | awk '\''{printf $1}'\'')"
  sudo -u "${user}" -H bash -c "echo \"$(id)\""
  
  browser="/usr/bin/chromium-browser"
  if [[ -f "/usr/bin/google-chrome" ]]; then browser="/usr/bin/google-chrome"; fi
 
  echo "before" > /tmp/out.log 
  nohup sudo -u "${user}" -H bash -c "DISPLAY=:1 "${browser}" "${url}"" &>/dev/null & disown
  
  echo "after" > /tmp/out.log 

  echo "Done"
fi'  | sudo tee -a  /etc/network/if-up.d/ewp
sudo chmod +x /etc/network/if-up.d/ewp

echo "DONE"

