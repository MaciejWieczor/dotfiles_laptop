terminal_open() {
	POSITION=$(xdotool getmouselocation --shell | grep "X=" | awk -F"=" '{print (NF>1)? $NF : ""}')
	if [[ $POSITION -gt 1920 ]]
	then
		FONT="-o font.size=11"
	else
		FONT=""
	fi
	alacritty $FONT --hold -e $1
}

timer_start () {
	$C_SCRIPT_DIR/timer_dmenu.sh
}

timer_stop () {
	$C_SCRIPT_DIR/timer_dmenu.sh 0
}

timer_menu () {
		CHOICE=$(printf "󱎫 rozpocznij minutnik\\n󱎬 zatrzymaj minutnik\\n󰈆 wyjście" | c_dmenu -l 4)
		case "$CHOICE" in
			*󱎫*) timer_start ;;
			*󱎬*) timer_stop ;;
			*󰈆*) exit ;;
		esac
}

transfer () { # pull photos from sd card into a folder for today's date

	mount() { # Check if the card is mounted
			sudo mount /dev/sda1 /mnt/sdcard && notify-send "SD zamontowane."
			[ -d /mnt/sdcard/DCIM/ ] || notify-send "SD nie zamontowane."

	}

	unmount() { # Unmount card
			sudo umount /mnt/sdcard && notify-send "SD odmontowane"
	}

	dt() { # Open darktable to import today's photos
			sudo umount /mnt/sdcard && notify-send "SD odmontowane, otwieranie Darktable"
			(darktable "$C_PHOTO_DIR$(date '+%b_%d')") &
	}

	postrun() { # Menu to select what I want to do after photos have been transferred
			notify-send "Zdjęcia przerzucono."
			choice=$(printf "Odmontuj SD\\nOtwórz Darktable, odmontuj\\nNic nie rób" | c_dmenu -l 3 -p "Zdjęcia zrzucono: ")
			case "$choice" in
					Odmontuj*) unmount;;
					Otwórz*) dt;;
					Nic*) exit 0;;
			esac
	}

	auto() { # Transfer photos from SD card into a directory for today's date
			[ -d /mnt/sdcard/DCIM/ ] || mount
			notify-send "Przerzucanie zdjęć rozpoczęte..."

			mkdir -p "$C_PHOTO_DIR/$(date '+%b_%d')"
			find /mnt/sdcard -type f -name "*.NEF" -exec mv -nv {} "$C_PHOTO_DIR/$(date '+%b_%d')/" \; && postrun
	}

	case "$1" in
			mount) mount ;;
			unmount) unmount ;;
			dt) dt ;;
			*) auto ;;
	esac
}

opendir () { # fuzzy find a dir to open in Darktable
		CHOICE=$(echo -e "Wpisz ścieżkę...\n$(command ls -t1 $C_PHOTO_DIR)" | c_dmenu -l 10 -p "Directory: ") || exit 0
				case $CHOICE in
						*Wpisz*) PHOTODIR="$(echo "" | c_dmenu -p "󰄄 Open: " <&-)" || exit 0 ;;
						*) PHOTODIR=$C_PHOTO_DIR/$CHOICE ;;
				esac

		darktable $PHOTODIR
}

photo_menu () {
		CHOICE=$(printf "󱁥 zrzuć zdjęcia z SD\\n otwórz folder w darktable\\n󰈆 wyjście" | c_dmenu -l 4)
		case "$CHOICE" in
			*󱁥*) transfer ;;
			**) opendir ;;
			*󰈆*) exit ;;
		esac
}

notatki () {
	$C_SCRIPT_DIR/dmenu_notes.sh
}

stopwatch_menu () {
	$C_SCRIPT_DIR/stopwatch.sh
}

vit () {
	terminal_open vit
}

krita_file () {
		CHOICE=$(printf "$(ls $C_DRAWING_DIR/Krita/)" | c_dmenu -l 4) || return 0
		krita $C_DRAWING_DIR/Krita/$CHOICE
}

milton_file () {
		CHOICE=$(printf "$(ls $C_DRAWING_DIR/Milton/)" | c_dmenu -l 4) || return 0
		$C_GITHUB_DIR/milton/build/Milton $C_DRAWING_DIR/Milton/$CHOICE
}

drawing_menu () {
		CHOICE=$(printf "  krita\\n  milton\\n  milton plik\\n krita plik\\n󰈆  wyjście" | c_dmenu -l 5 -p "Menu Rysowania")
		case "$CHOICE" in
			**) krita ;;
			**) $C_GITHUB_DIR/milton_fork/build/Milton ;;
			**) milton_file ;;
			**) krita_file ;;
			*󰈆*) exit ;;
		esac
}

cmd_archive () {
	$C_SCRIPT_DIR/command_archive.sh
}

cmd_category () {
	$C_SCRIPT_DIR/command_archive_parser.sh
}

bookmark_category () {
	$C_SCRIPT_DIR/bookmark_parser.sh
}

bookmark_archive () {
        $C_SCRIPT_DIR/bookmark_archive.sh
}

cmd_menu () {
		CHOICE=$(printf "  archiwum komend\\n  kategorie komend\\n  edytuj zapisane komendy\\n󰈆  exit" | c_dmenu -l 10) || exit 0
		case "$CHOICE" in
			**) cmd_archive ;;
			**) cmd_category ;;
			**) terminal_open "nvim $C_CMD_ARCHIVE" ;;
			*󰈆*) exit ;;
		esac
}

bookmark_menu () {
		CHOICE=$(printf " zakładki\\n󰸕 kategorie zakładek\\n  edytuj zapisane zakładki\\n󰈆  exit" | c_dmenu -l 10) || exit 0
		case "$CHOICE" in
			**) bookmark_archive ;;
			*󰸕*) bookmark_category ;;
			**) terminal_open "nvim $C_BOOKMARKS" ;;
			*󰈆*) exit ;;
		esac
}

music_player_menu () {
		CHOICE=$(printf "󰈣 find song\\n󰈆 exit" | c_dmenu -l 4)
		case "$CHOICE" in
			*󰈣*) $C_SCRIPT_DIR/music_dmenu_picker.sh ;;
			*󰈆*) exit ;;
		esac
}

guitar_menu () {
		CHOICE=$(printf "󰲹 open tab\\n󰈆 exit" | c_dmenu -l 4)
		case "$CHOICE" in
			*󰲹*) $C_SCRIPT_DIR/dmenu_tab_picker.sh ;;
			*󰈆*) exit ;;
		esac
}

video_cmd () {
	CHOICE=$(printf "$(find ~/Wideo -type f -exec file -N -i -- {} + | sed -n 's!: video/[^:]*$!!p' | sort)" | c_dmenu -l 15)
	mpv --save-position-on-quit $CHOICE
}

menu() {
		CHOICE=$(printf "󱎫  minutnik\\n  stoper\\n  menu zdjęć\\n󰎄  music player\\n󰋄  guitar\\n󰽉  menu rysowania\\n  archiwum komend\\n  zakładki\\n  vit lista todo\\n  notatki\\n  filmy i seriale\\n󰈆  wyjście" | c_dmenu -l 100)
		case "$CHOICE" in
			*󱎫*) timer_menu ;;
			**) stopwatch_menu ;;
			**) photo_menu ;;
			*󰎄*) music_player_menu ;;
			*󰋄*) guitar_menu ;;
			*󰽉*) drawing_menu ;;
			**) notatki ;;
			**) cmd_archive ;;
			**) bookmark_menu ;;
			**) vit ;;
			**) video_cmd ;;
			*󰈆*) exit ;;
		esac
}

"$@"
