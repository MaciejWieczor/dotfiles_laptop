#!/bin/bash
# just read a file full of emojis with small description
# doesn't have to be a particular file
CHOICE=$(printf "$(cat ~/.config/emoji_db/unified_emoji_file)" | \
	c_dmenu -l 20 -p "Wybierz emoji:") || exit 0

echo -n $CHOICE | cut -d ' ' -f1 | tr -d '\n' | xclip -selection clipboard && notify-send "Ikona $CHOICE skopiowana"
