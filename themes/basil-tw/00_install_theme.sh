#!/bin/sh
#############################################################################
# Install GRUB2 theme
############################################ Working Directory & Variable ###
cd "$(dirname "$0")"

theme_name=basil-tw
install_path=/boot/grub/themes
zip_path=~/Desktop

################################################################# Process ###
read -p "(I)nstall theme or (C)reate zip file on desktop (I/C) ? " ans

case $ans in
I) # Install
    sudo mkdir -p $install_path/$theme_name
    yes | sudo cp -r ./* $install_path/$theme_name
    echo 'Install completed.'
;;
C) # Create
    zip -FSr $zip_path/$theme_name ./*
    echo 'Create completed.'
;;
*)
    echo 'Do nothing.'
;;
esac


