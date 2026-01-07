#!/usr/bin/env bash

folder=$HOME/Notatki/Tekst/

daily_note() {
	dir=$folder"Kalendarz/$(date +%Y/%m/)"
	name="$(date +%Y_%m_%d).md"
	mkdir -p $dir;
	setsid -f alacritty -e nvim $dir$name >/dev/null 2>&1
	exit 0
}


newnote () { \
	CHOICE=$(echo -e "Data\\n$(command ls -d "$folder" "$folder"*/)\nWpisz ścieżkę..." | c_dmenu -l 10 -p "Directory: ") || exit 0
	case $CHOICE in
		*Data*) daily_note ;;
		*$folder*) dir=$folder ;;
		*Wpisz*) dir="$(echo "" | c_dmenu -p "Katalog notatek: " <&-)" || exit 0 ;;
		*) exit 0;;
	esac

	CHOICE=$(echo -e "Wpisz nazwę notatki...\\nData" | c_dmenu -l 10 -p "Directory: ") || exit 0
	case $CHOICE in
		*Wpisz*) name="$(echo "" | c_dmenu -p "Nazwa notaki: " <&-)" || exit 0 ;;
		*Data*) name=$(date +%F_%H-%M-%S) ;;
		* ) exit 0;;
	esac

	setsid -f alacritty -e nvim $dir$name".md" >/dev/null 2>&1
}

selected () { \
  choice=$(
    echo -e "󰎜 New\n Dziennik\n$(find $folder -type f -printf '%T@ %P\n' | sort -nr | cut -d' ' -f2-)" | c_dmenu -l 10 -p "Choose note or create new: "
  )
  case $choice in
	*󰎜*) newnote ;;
    	**) daily_note ;;
    	*.md) setsid -f alacritty -e nvim "$folder$choice" >/dev/null 2>&1 ;;
	*) exit ;;
  esac
}

selected
