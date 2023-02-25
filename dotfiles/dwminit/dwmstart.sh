#!/bin/sh

###Status bar
statusbar.sh &
###Aplicaciones inicio
feh --bg-scale /home/alc111/repos/DWM/wallpaper/griffith.png &
picom &
#setxkbmap -layout es &
#pnmixer &
#volctl &
nm-applet &
dunst &
#cbatticon &
#blueman-applet &
#flameshot &
exec dwm
