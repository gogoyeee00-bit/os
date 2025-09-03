#!/bin/bash
REPO="https://raw.githubusercontent.com/gogoyeee00-bit/os/main/"
apt install rclone
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "${REPO}install/rclone.conf"
git clone  https://github.com/gogoyeee00-bit/wondershaper.git
cd wondershaper
make install
cd
rm -rf wondershaper
wget -q ${REPO}install/limit.sh && chmod +x limit.sh && ./limit.sh
    
rm -f /root/set-br.sh
rm -f /root/limit.sh
