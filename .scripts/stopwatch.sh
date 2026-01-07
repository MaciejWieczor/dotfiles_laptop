#!/bin/bash
trap cleanup SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM # 1 2 3 6 15

cleanup() {
	echo "" > /tmp/stopwatch_status
	echo "" > /tmp/stopwatch
	TOTAL_SECONDS=0
	LAP_COUNT=0
	echo "" >> ~/stoper_log.txt
	pkill -RTMIN+3 i3blocks;
	exit 0
}

main_loop () {
	while [ $(cat /tmp/stopwatch_status) == 'RUNNING' ]; do
		TOTAL_SECONDS=$(cat /tmp/stopwatch);
		((TOTAL_SECONDS++))
		echo $TOTAL_SECONDS > /tmp/stopwatch;
		pkill -RTMIN+3 i3blocks;
		sleep 1
	done
}

init () {
	echo "RUNNING" > /tmp/stopwatch_status
	echo 0 > /tmp/lap_count
	echo 0 > /tmp/last_lap
	$LAP_COUNT=$((0))
	TOTAL_SECONDS=$((0))
	echo $TOTAL_SECONDS > /tmp/stopwatch;
	pkill -RTMIN+3 i3blocks;
	sleep 1
	((TOTAL_SECONDS++))
	echo $TOTAL_SECONDS > /tmp/stopwatch;
	pkill -RTMIN+3 i3blocks;
	sleep 1
	main_loop
	# cleanup
}

resume () {
	echo "RUNNING" > /tmp/stopwatch_status
	main_loop
}

pause () {
	echo "PAUSE" > /tmp/stopwatch_status
	pkill -RTMIN+3 i3blocks;
}

reset () {
	cleanup
}

lap () {
	LAP_COUNT=$(cat /tmp/lap_count)
	((LAP_COUNT++))
	LAST_LAP=$(cat /tmp/last_lap)
	TOTAL_SECONDS=$(cat /tmp/stopwatch)
	LAP_DIFF=$((TOTAL_SECONDS-LAST_LAP))
	HRS=$(printf "%02d" $((LAP_DIFF / 3600)))
	MIN=$(printf "%02d" $(((LAP_DIFF % 3600) / 60)))
	SEC=$(printf "%02d" $((LAP_DIFF % 60)))
	HRS_TOTAL=$(printf "%02d" $((TOTAL_SECONDS / 3600)))
	MIN_TOTAL=$(printf "%02d" $(((TOTAL_SECONDS % 3600) / 60)))
	SEC_TOTAL=$(printf "%02d" $((TOTAL_SECONDS % 60)))
	LAP_TEXT="$LAP_COUNT $(date +%Y/%m/%d) - $HRS:$MIN:$SEC - total $HRS_TOTAL:$MIN_TOTAL:$SEC_TOTAL"
	echo $LAP_TEXT >> ~/stoper_log.txt
	dunstify "Przerwa : $LAP_TEXT"
	echo $LAP_COUNT > /tmp/lap_count
	echo $TOTAL_SECONDS > /tmp/last_lap
}

lap_stop () {
	pause
	lap
}

start () {
	if [ -e /tmp/stopwatch ]; then
		if [ ! -s /tmp/stopwatch ]; then
			init # plik istnieje ale jest pusty
		else
			resume # plik istnieje i nie jest pusty, kontynuuj
		fi
	else
		init # plik nie istnieje
	fi
}

menu () {
		CHOICE=$(printf "󱎫 start\\n󰑌 okrążenie\\n okrążenie i stop\\n󱫪 stop\\n󰜉 reset\\n󰈆 wyjście" | c_dmenu -l 6 -p "Stoper - opcje")
		case "$CHOICE" in
			*󱎫*) start ;;
			*󰑌*) lap ;;
			**) lap_stop ;;
			*󱫪*) pause ;;
			*󰜉*) reset ;;
			*󰈆*) exit 0 ;;
		esac
}

case "$#" in
		0) menu ;;
		1) notify-send "Wyłączanie stopera" & kill -TERM $(pgrep -f $C_SCRIPT_DIR/stopwatch.sh) ;;
esac
