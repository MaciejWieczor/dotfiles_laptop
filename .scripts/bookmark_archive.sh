#!/bin/bash

CHOICE=$(printf "$(grep "^[^#-]" $C_BOOKMARKS | sed '1d')" | \
	c_dmenu -l 50 -p "Wybierz zakładkę: ") || exit 0
CHOICE=${CHOICE%#*}
echo -n $CHOICE | xclip -selection clipboard && notify-send "$CHOICE copied to clipboard"
