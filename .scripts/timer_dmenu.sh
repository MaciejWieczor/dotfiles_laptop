#!/bin/bash
trap cleanup SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM # 1 2 3 6 15

cleanup() {
	echo "" > /tmp/timericon;
	TOTAL_SECONDS=0
	pkill -RTMIN+3 i3blocks;
	exit 0
}

timer () {
	while [ $TOTAL_SECONDS -gt 0 ]; do
		TOTAL_SECONDS=$(cat /tmp/timericon);
		((TOTAL_SECONDS--))
		echo $TOTAL_SECONDS > /tmp/timericon;
		pkill -RTMIN+3 i3blocks;
		sleep 1
	done

	notify-send "Minutnik skończył pracę"
	cleanup
}

init () {
		MINUTES="$(echo "" | c_dmenu -p "Minutes: " <&-)"
		TOTAL_SECONDS=$((MINUTES * 60))
		if [ $TOTAL_SECONDS == 0 ]; then
			cleanup
		fi
		echo $TOTAL_SECONDS > /tmp/timericon;
		pkill -RTMIN+3 i3blocks;
		timer
}

case "$#" in
		0) init ;;
		1) notify-send "Wyłączanie minutnika" & kill -TERM $(pgrep -f $C_SCRIPT_DIR/timer_dmenu.sh) ;;
esac
