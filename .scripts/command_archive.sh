#!/bin/bash

CHOICE=$(printf "$(grep "^[^#-]" $C_CMD_ARCHIVE | sed '1d')" | \
	c_dmenu -l 10 -p "Wybierz komendę: ") || exit 0
CHOICE=${CHOICE%#*}
echo -n $CHOICE | xclip -selection clipboard && notify-send "$CHOICE copied to clipboard"
