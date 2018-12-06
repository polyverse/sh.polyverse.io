#!/bin/sh

cat docs/header.txt | grep -v ^# > usage.txt

SCRIPTS="$(ls scripts | grep -v \\.)"

for SCRIPT in $SCRIPTS; do
	PAD="$(printf '%0.1s' " "{1..20})"
	PAD_LENGTH="20"

	if [ ${#SCRIPT} -gt $PAD_LENGTH ]; then
		echo "ERROR: script name must be <= $PAD_LENGTH."
		exit 1
	fi

	col1="$(printf '%s%*.*s' "$SCRIPT" 0 $((PAD_LENGTH - ${#SCRIPT} )) "$PAD")"
	while read LINE; do
		if [ -z "$LINE" ]; then
			echo "[WARN] script '$SCRIPT' is missing \"SHORT_DESCRIPTION=\". Skipping..."
			continue
		fi
		printf "%s  %s\n" "$col1" "$LINE" >> usage.txt
		col1="$PAD"
	done <<< "$(cat scripts/$SCRIPT | sed -n -E "s/^SHORT_DESCRIPTION=\"(.*)\"/\1/p" | fold -w 60 -s)"
done

cat docs/footer.txt | grep -v ^# >> usage.txt

rm -frd out/
mkdir -p out/scripts

cp main.sh ./out/
cp usage.txt ./out/
cp -a ./scripts/. ./out/scripts/
