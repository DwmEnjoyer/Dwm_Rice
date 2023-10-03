#!/bin/sh

# Options for powermenu
logout=""
shutdown=""
reboot=""

# Get answer from user via rofi
selected_option=$(echo "$logout
$reboot
$shutdown" | rofi -dmenu\
                  -i\
                  -p "Power"\
                  -theme "~/.config/rofi/powermenu.rasi")
# Do something based on selected option
if [ $selected_option = $logout ]
then
	loginctl kill-user $(whoami)
elif [ $selected_option = $shutdown ]
then
    shutdown -h now
elif [ $selected_option = $reboot ]
then
    reboot
else
    echo "No match"
fi