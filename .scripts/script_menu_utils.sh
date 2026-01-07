terminal_open() {
	POSITION=$(xdotool getmouselocation --shell | grep "X=" | awk -F"=" '{print (NF>1)? $NF : ""}')
	if [[ $POSITION -gt 1920 ]]
	then
		FONT="-o font.size=11"
	else
		FONT=""
	fi
	alacritty $FONT "$@"
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

notatki () {
	$C_SCRIPT_DIR/dmenu_notes.sh
}

stopwatch_menu () {
	$C_SCRIPT_DIR/stopwatch.sh
}

vit () {
	terminal_open vit
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

menu() {
		CHOICE=$(printf "󱎫  minutnik\\n  stoper\\n  archiwum komend\\n  zakładki\\n  vit lista todo\\n  notatki\\n󰈆  wyjście" | c_dmenu -l 100)
		case "$CHOICE" in
			*󱎫*) timer_menu ;;
			**) stopwatch_menu ;;
			**) notatki ;;
			**) cmd_archive ;;
			**) bookmark_menu ;;
			**) vit ;;
			*󰈆*) exit ;;
		esac
}

"$@"
