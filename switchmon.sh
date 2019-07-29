#/bin/bash
# monitor switch script with variables
# wrapped up with pygtk program
# thanks jon almeida blog post

hdmicard=$(pacmd list-sinks | awk '/name:/ {print $0};' | awk '{ print $2}' | sed 's/<//g; s/>//g' | grep hdmi)
analogcard=$(pacmd list-sinks | awk '/name:/ {print $0};' | awk '{ print $2}' | sed 's/<//g; s/>//g' | grep analog)

dvimonitor=$(xrandr | grep -E " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/" | grep DVI)
vgamonitor=$(xrandr | grep -E " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/" | grep VGA)
hdmitv=$(xrandr | grep -E " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/" | grep HDMI)

while [ ! $# -eq 0 ]
do

	case "$1" in
	--hdtv)
		# HDMI TV only
		xrandr --output DVI-D-0 --off --output VGA-1-1 --off --output $hdmitv --primary --mode 1920x1080 -r 60 --pos 0x0 --rotate normal --dpi 120 &
		pacmd set-default-sink $hdmicard
		xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 69
		xfconf-query -c xfwm4 -p /general/theme -s RedmondXP-hidpi
		xfconf-query --channel xsettings --property /Gtk/CursorThemeSize --set 48
		xfconf-query -c xsettings -p /Xft/DPI -s 190
		pactl -- set-sink-volume $hdmicard 100%
		pacmd set-default-sink $hdmicard
		exit
			;;
		--hdmon)

		# HD Monitor only
		xrandr --output $dvimonitor --mode 1920x1080 --rotate normal --output $hdmitv --off --output VGA-1-1 --off --dpi 96 &
		pacmd set-default-sink $analogcard
		xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 59
		xfconf-query -c xfwm4 -p /general/theme -s RedmondXP
		xfconf-query --channel xsettings --property /Gtk/CursorThemeSize --set 24
		xfconf-query -c xsettings -p /Xft/DPI -s 100
		pactl -- set-sink-volume $analogcard 100%
		exit
			;;
		--crtmon)
		# CRT Monitor only
		pacmd set-default-sink $analogcard
		pactl -- set-sink-volume $analogcard 100%
		killall steam
		xrandr --output $vgamonitor --mode 640x480 --rate 60 --output $hdmitv --off --output $dvimonitor --off
		xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 39
		xfconf-query -c xfwm4 -p /general/theme -s RedmondXP
		xfconf-query --channel xsettings --property /Gtk/CursorThemeSize --set 16
		xfconf-query -c xsettings -p /Xft/DPI -s 100
		export GDK_SCALE=
		xrandr --output VGA-1-1 --mode 640x480 --rate 85 --output HDMI-0 --off
		steam-native -silent
		exit
			;;
	esac
done
