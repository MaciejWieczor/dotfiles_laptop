#!/bin/bash
TOTAL_SECONDS=$(cat /tmp/timericon)
if [[ "$TOTAL_SECONDS" -le 0 ]]; then
	exit 0
fi

MIN=$(printf "%02d" $((TOTAL_SECONDS / 60)))
SEC=$(printf "%02d" $((TOTAL_SECONDS % 60)))
printf "%s %s %s\n" "M" $MIN $SEC
