#!/bin/sh

# This is how many minutes a snooze is
SNOOZE=1

if [ "$#" = 0 ]; then
	# Turn screen on
	xset s reset
	# Actual Alarming
	"$(dirname "$0")/alarm"

	amount="now + $SNOOZE minutes"
else
	amount="$*"
fi

# This is the length of a snooze
echo "DISPLAY=$DISPLAY xterm -e $0" | at $amount

# Turn off screen
xset s activate
