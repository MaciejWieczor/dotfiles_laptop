#!/bin/bash

terminal_open() {
	POSITION=$(xdotool getmouselocation --shell | grep "X=" | awk -F"=" '{print (NF>1)? $NF : ""}')
	if [[ $POSITION -gt 1920 ]]
	then
		FONT="-o font.size=11"
	else
		FONT=""
	fi
	alacritty $FONT --hold -e $@
}

cd $C_KERNEL_SRC

# input the version numer
VERSION="$(echo "" | c_dmenu -p "Wpisz numer wersji: " <&-)" || exit 0

# use some existing directory or create a new one
cd $C_KERNEL_SRC/patches
CHOICE=$(printf "Wpisz ręcznie nazwę serii\\n$(ls -d ./*)" | c_dmenu -l 10 -p "Wybierz katalog dla patchy: ") || exit 0
case "$CHOICE" in
	*Wpisz*) DIR_NAME="$(echo "" | c_dmenu -p "Wpisz nazwę dla serii: " <&-)" || exit 0 ; FINAL_DIR="${DIR_NAME}_v${VERSION}" ;;
	*) DIR_NAME=$CHOICE; mv $DIR_NAME ${DIR_NAME}_del ; FINAL_DIR=$DIR_NAME ;;
esac
cd $C_KERNEL_SRC

# browse tags or input patch range manually
CHOICE=$(printf "Wpisz ręcznie\\n$(git tag)" | c_dmenu -l 10 -p "Wybierz zakresy patchy: ") || exit 0
case "$CHOICE" in
	*Wpisz*) PATCH_RANGE="$(echo "" | c_dmenu -p "Wpisz zakres patchy: " <&-)" || exit 0 ;;
	*) PATCH_RANGE=$CHOICE ;;
esac
COMMAND="$C_SCRIPT_DIR/$1 $VERSION $FINAL_DIR $PATCH_RANGE"

terminal_open $COMMAND
exit 0

