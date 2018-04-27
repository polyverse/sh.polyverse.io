#!/bin/sh

SCRIPTS="$(ls scripts | grep -v \\.)"

for SCRIPT in $SCRIPTS; do
	STR="$(cat scripts/$SCRIPT | sed -n -E "s/^SHORT_DESCRIPTION=\"(.*)\"/\1/p")"
	printf "%s           %s\n" $SCRIPT "$STR"
done
