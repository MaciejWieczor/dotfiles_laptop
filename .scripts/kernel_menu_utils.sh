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

open_kernel_config () {
		CHOICE=$(printf "Yes\\nNo\\n󰈆 exit" | c_dmenu -l 4 -p "Enable LLVM?") || exit 0
		case "$CHOICE" in
			*Yes*) LLVM="LLVM=1";;
			*No*) LLVM="" ;;
		esac
		terminal_open "make -j10 $LLVM O=$C_KERNEL_BUILD nconfig"

}

compile_kernel() {
	exit 0
}

build_menu () {
	CHOICE=$(printf " open kernel config\\n󰣪 compile the kernel\\n󰈆 exit" | c_dmenu -l 4) || exit 0
	case "$CHOICE" in
		**) open_kernel_config ;;
		*󰣪*) compile_kernel ;;
		*󰈆*) exit ;;
	esac
}

# run the patchset_format script
# first collect all the needed data, some input, some pick from the list
patchset () {
	$C_SCRIPT_DIR/patchset_helper.sh $1
}

prepare_patchset () {
	patchset "patchset_format.sh"
}

email_prepare_patchset () {
	patchset "dmenu_git_sendemail.sh"
}

patches_menu () {
	CHOICE=$(printf "󰙷 przygotuj łatki\\n󰇮 przygotuj i wyślij łatki\\n󰈆 exit" | c_dmenu -l 10)
	case "$CHOICE" in
		*󰙷*) prepare_patchset ;;
		*󰇮*) email_prepare_patchset ;;
		*󰈆*) exit ;;
	esac

}

nvim_menu () {
	SESSION_PATH=$HOME/.local/share/nvim/session/
	CHOICE=$(printf "$(ls $SESSION_PATH)" | c_dmenu -l 20 -p "Wybierz sesję neovim: ") || exit 0
	terminal_open nvim -S $SESSION_PATH$CHOICE
}

menu () {
		CHOICE=$(printf "󰣪 menu kompilacji\\n menu łatek\\n menu neovim\\n󰈆 exit" | c_dmenu -l 10)
		case "$CHOICE" in
			*󰣪*) build_menu ;;
			**) patches_menu ;;
			**) nvim_menu ;;
			*󰈆*) exit ;;
		esac
}

"$@"
