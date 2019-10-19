#/bin/bash

# This script is cleanning all system level Linux/Gnome shortcuts that conflicts with IntelliJ Default Keymap Schema Shortcuts
# List of conflicts is available here: https://www.jetbrains.com/help/idea/configuring-keyboard-and-mouse-shortcuts.html#conflicts

VERSION=20191019
GSETTINGS=/usr/bin/gsettings
GSETTINGS_SCHEMA=org.gnome.desktop.wm.keybindings

function info() {
	MSG=$1
	echo "$MSG"
}

function warn() {
	MSG=$1
	echo "Warning: $MSG"
}

function err() {
	ERROR=$1
	echo "Error: $ERROR"
	exit 1
}

function header() {
	info "IntelliJ Default Keymap Schema Shortcuts Conflict Cleaner"
	info "Version $VERSION"
	info ""
}

function displayHelp() {
	info "-h | --help - display this help info"
	info "-c | --clear - clear system shortcut keys conflicting with IntelliJ"
	info "-r | --restore - restore all default system level shortcut keys"
}

function validateEnv() {
	if [ ! -f $GSETTINGS ]; 
	then
		err "Expected gsettings in following location: $GSETTINGS"
	fi
}

function getShortcutKeyName() {
	SHORTCUT=$1
	echo $($GSETTINGS list-recursively |grep $GSETTINGS_SCHEMA |grep -Fi "${SHORTCUT}" |awk '{ print $2; }')
}

function getShortcutValue() {
	SHORTCUT_KEY=$1
	echo $($GSETTINGS get $GSETTINGS_SCHEMA $SHORTCUT_KEY)
}

function clearShortcutValue() {
	SHORTCUT_KEY=$1

	$GSETTINGS set $GSETTINGS_SCHEMA $SHORTCUT_KEY '[]'

	if [ $? -ne 0 ];
	then
		err "Received non-zero $? exit code from gsettings for $SHORTCUT_KEY"
	fi
}

function clearShortcutKey() {
	SHORTCUT=$1

	SHORTCUT_KEY=$(getShortcutKeyName $SHORTCUT)

	if [ ! -z "$SHORTCUT_KEY" ];
        then
		SHORTCUT_OLD_VALUE=$(getShortcutValue $SHORTCUT_KEY)

		clearShortcutValue $SHORTCUT_KEY $SHORTCUT

		SHORTCUT_NEW_VALUE=$(getShortcutValue $SHORTCUT_KEY)
		info "Shortcut $SHORTCUT cleared"
	else
		warn "Shortcut value not found for $SHORTCUT, skipping..."
	fi
}

function clearShortcutKeys() {
	info "Clearing Shortcut Keys Conflicts..."

	clearShortcutKey "['<Control><Alt>Left']"
	clearShortcutKey "['<Control><Alt>Right']"
        clearShortcutKey "['<Alt>F7']"
	clearShortcutKey "['<Alt>F8']"
	clearShortcutKey "['<Control><Alt>S']"
	clearShortcutKey "['<Control><Alt>L']"
	clearShortcutKey "['<Control><Alt>T']"
	clearShortcutKey "['<Control><Alt>F12']"

	info "Done"
}

function restoreShortcutKeys() {
	info "Restoring all Shortcut Keys..."
	
	$GSETTINGS reset-recursively $GSETTINGS_SCHEMA

	if [ $? -eq 0 ];
	then
		info "Done"
	else
		err "Received non-zero $? exit code from gsettings"
	fi
}

header
validateEnv

COMMAND=$1

case $COMMAND in
	-h|--help)
		displayHelp
		;;
	-c|--clear)
		clearShortcutKeys
		;;
	-r|--restore)
		restoreShortcutKeys
		;;
	*)
		displayHelp
		;;
esac

