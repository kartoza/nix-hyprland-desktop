#!/bin/bash
clear
aur_helper="$(cat /etc/xdg/ml4w/settings/aur.sh)"
figlet -f smslant "Cleanup"
echo
$aur_helper -Scc
