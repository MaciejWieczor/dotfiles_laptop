#!/usr/bin/env bash

ranczo_mode() {
	trap cleanup SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM # 1 2 3 6 15

	cleanup() {
		echo "" > /tmp/timershtd;
		TOTAL_SECONDS=0
		pkill -RTMIN+3 i3blocks;
		exit 0
	}

	timer () {
		while [ $TOTAL_SECONDS -gt 0 ]; do
			TOTAL_SECONDS=$(cat /tmp/timershtd);
			((TOTAL_SECONDS--))
			echo $TOTAL_SECONDS > /tmp/timershtd;
			pkill -RTMIN+3 i3blocks;
			sleep 1
		done
		cleanup
	}

	cancel () {
		shutdown -c;
		notify-send "Odsunięte wyłączenie anulowane"
		cleanup
	}

	init () {
			MINUTES="$(echo "" | c_dmenu -p "Minutes: " <&-)"
			TOTAL_SECONDS=$((MINUTES * 60))
			shutdown -h $MINUTES
			notify-send "Komputer zostanie wyłączony za $MINUTES minut"
			if [ $TOTAL_SECONDS == 0 ]; then
				cleanup
			fi
			echo $TOTAL_SECONDS > /tmp/timershtd;
			pkill -RTMIN+3 i3blocks;
			timer
	}

	case "$1" in
			'init') init ;;
			'cancel') cancel ;;
			'kill') notify-send "Killing timer..." & kill -TERM $(pgrep -f ~/.scripts/powerdmenu.sh) ;;
	esac
}

case "$(printf "󰆴 kill process\\n󰒲 zzz\\n󰜉 reboot\\n shutdown\\n󰈆 exit menu" | c_dmenu -l 10)" in
	*󰆴*) ps -u $USER -o pid,comm,%cpu,%mem | dmenu -l 10 -p Kill: | awk '{print $1}' | xargs -r kill ;;
	*󰒲*) slock systemctl suspend -i ;;
	*󰜉*) systemctl reboot -i ;;
	**) shutdown now ;;
	*󰈆*) exit ;;
	*) exit 1 ;;
esac
