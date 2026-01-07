#!/bin/bash

CHOICE=$(printf "$(cat $C_CMD_ARCHIVE | grep -n ^# | sed 's/^.*://')" | \
	c_dmenu -l 10 -p "Wybierz kategorię komend: ") || exit 0

FIRST=$(cat $C_CMD_ARCHIVE | grep -n ^# | sed 's/:/ /' |
	grep -A1 "$CHOICE" | awk '{print $1}' | head -1)
LAST=$(cat $C_CMD_ARCHIVE | grep -n ^# | sed 's/:/ /' |
	grep -A1 "$CHOICE" | awk '{print $1}' | tail -1)

if [[ $FIRST = $LAST ]]; then
	LAST=$(( $(wc -l $C_CMD_ARCHIVE | awk '{print $1}') + 1 ))
fi


CHOICE=$(printf "$(sed -n $(( FIRST + 1 )),$(( LAST - 2 ))p $C_CMD_ARCHIVE)" | \
	c_dmenu -l 10 -p "Wybierz komendę: ") || exit 0

echo -n $CHOICE | xclip -selection clipboard && notify-send "$CHOICE skopiowany"
