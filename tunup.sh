#!/bin/bash

set -x
echo "Turning on ${IFACE}" > /tmp/bla.log
if [[ "${IFACE}" == "tun0" ]]; then 
  echo "Handling ${IFACE} " >> /tmp/bla.log
  
  url="https://"
  user="$(who | grep ":1" | awk '{printf $1}')"
  sudo -u "${user}" -H bash -c "echo \"$(id)\" >> /tmp/bla.log"
  sudo -u "${user}" -H bash -c "DISPLAY=:1 /usr/bin/chromium-browser ${url} >> /tmp/bla.log"
  
  echo "Done"
fi
