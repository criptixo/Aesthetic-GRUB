#!/bin/sh
#############################################################################
# Config GRUB2 theme for basil-tw
############################################ Working Directory & Variable ###
cd "$(dirname "$0")"

theme_path=/boot/grub/themes/basil-tw

################################################################# Process ###
echo "========= Avoid the time difference between Linux & Windows ==========="
timedatectl set-local-rtc 1

#echo "========= OS Icon: Remove the file that make Linux Mint as Ubuntu ====="
#sudo mv /etc/default/grub.d/50_linuxmint.cfg /etc/default/grub.d/50_linuxmint.cfg.bak

echo "=============== Config /etc/defalut/grub =============================="
echo "GRUB_THEME=$theme_path/theme.txt" | sudo tee -a /etc/default/grub

echo "=============== Set lastest choice as default ========================="
echo "GRUB_DEFAULT=saved" | sudo tee -a /etc/default/grub
echo "GRUB_SAVEDEFAULT=true" | sudo tee -a /etc/default/grub

echo "=============== Update GRUB2 Config ==================================="
sudo update-grub2

echo "=============== Done, please reboot system ============================"


