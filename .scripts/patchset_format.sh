# $1 - version number
# $2 - directory name for patches
# $3 - patch range (for example HEAD~20)
# $4 - additional emails

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

LAST_PWD=$(pwd)
SOURCE=$C_KERNEL_SRC
PATCHES=$C_KERNEL_SRC/patches
CHANGELOG_SCRIPT=$C_SCRIPT_DIR/git-scripts/changelog_run.py
MAINTAINERS_SCRIPT=$C_SCRIPT_DIR/git-scripts/cover_maintainer.py
SENDING_SCRIPT="$PATCHES/$2/send_cmds"

rm -rf $PATCHES/$2/
cd $SOURCE && \
git -c "user.email=$DEV_EMAIL" format-patch -v $1 --thread --cover-letter --cover-from-description=subject --from="$DEV_NAME <$DEV_EMAIL>" -o $PATCHES/$2/ $3 && \
python $CHANGELOG_SCRIPT -i $PATCHES/$2/ && \
$C_KERNEL_SRC/scripts/checkpatch.pl $PATCHES/$2/changelog/* --codespell --strict
python $MAINTAINERS_SCRIPT -k $SOURCE -i $PATCHES/$2/changelog/ -g="$4 --confirm=always --cc=m.wieczorretman@pm.me" -d > $SENDING_SCRIPT
echo 'git -c "user.email='$DEV_EMAIL'" send-email --identity=kernel --confirm=always --cc='$DEV_EMAIL $PATCHES'/'$2'/changelog/*' >> $SENDING_SCRIPT
cd $LAST_PWD
terminal_open nvim $SENDING_SCRIPT
