#!/bin/sh

cat docs/header.txt | grep -v ^# > usage.txt

SCRIPTS="$(ls scripts | grep -v \\.)"

for SCRIPT in $SCRIPTS; do
	STR="$(cat scripts/$SCRIPT | sed -n -E "s/^SHORT_DESCRIPTION=\"(.*)\"/\1/p")"
	if [ ! -z "$STR" ]; then
		printf "%s           %s\n" $SCRIPT "$STR" >> usage.txt
	fi
done

cat docs/footer.txt | grep -v ^# >> usage.txt
