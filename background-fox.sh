#!/bin/bash
#author:	Joshua Hartwell
#website:	www.joshuad.net
#license:	GPL v3.0
#version:	1

set -x

command -v date >/dev/null 2>&1 || { echo >&2 "I require date but it's not installed.  Aborting."; exit 1; }
command -v gsettings >/dev/null 2>&1 || { echo >&2 "I require 'gsettings' but it's not installed.  Aborting."; exit 1; }

DATE=`command -v date`
GSETTINGS=`command -v gsettings`

current_directory=`readlink -f $(dirname $0)`
pic_folder="$current_directory/imgs/"
log="/dev/null" #"$current_directory/background-fox.log"
hour=`$DATE +"%H"`
minute=`$DATE +"%M"`

echo -e "\nCalled at Hour: $hour, Minute: $minute" >> $log 2>&1

if [[ $hour -eq "3" && $minute -eq "14" ]] ; then
	target="0314.jpg"
elif [[ $hour -eq "3" && $minute -ge "16" ]] ; then
	target="04.jpg"
elif [[ $[$hour % 2] -eq "0" ]] ; then 
	target="$hour.jpg"
else  
	hour=$((hour-1))
	if [[ $hour -le "9" ]] ; then
		hour="0$hour"
	fi
	target="$hour.jpg"
fi

img_file=$pic_folder$target

if [[ -f $img_file ]] ; then
   this_path=$(dirname "$0")
   DWM=$($this_path/dename.sh -n)

   case "$DWM" in
      ("GNOME") 
         PID=$(pgrep --uid 1000 gnome-session)
         export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-) >>$log 2>&1
         gsettings set org.gnome.desktop.background picture-options "scaled" >>$log 2>&1
         gsettings set org.gnome.desktop.background picture-uri file://$pic_folder$target >>$log 2>&1
         echo "Background set to image: $img_file" >> $log 2>&1
         ;;
      ("KDE") 
         echo "KDE not supported" 
         ;;
      ("UNITY") 
         echo "UNITY not supported" 
         ;;
      ("XFCE") 
         PID=$(pgrep xfce4-session)
         export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-) >>$log 2>&1
         img_targets=( $(xfconf-query -c xfce4-desktop -l | grep "last-image$" | tr '\n' ' ') )

         for property in "${img_targets[@]}" ; do
           xfconf-query --channel xfce4-desktop --property $property --set $pic_folder$target
         done

         style_targets=( $(xfconf-query -c xfce4-desktop -l | grep "image-style$" | tr '\n' ' ') )
         for property in "${style_targets[@]}" ; do
           xfconf-query --channel xfce4-desktop --property $property -s 4
         done


         echo "Background set to image: $img_file" >> $log 2>&1
         echo "XFCE" 
         ;;
      ("CINNAMON") 
         echo "CINNAMON not supported" 
         ;;
      ("MATE") 
         echo "MATE not supported" 
         ;;
      ("LXDE") 
         echo "LXDE not supported"
         ;;
      ("SUGAR") 
         echo "SUGAR not supported" 
         ;;
   esac


else
	echo "Image $img_file does not exist, background not changed."
fi

