#!/bin/sh

INSTALL_ROOT=$PWD

echo "Scanning $INSTALL_ROOT..."
find $INSTALL_ROOT/ -name \* -print | while read line; do
        TARGET="$(echo $line | sed 's|'$INSTALL_ROOT'/||g')"
        if [ "$INSTALL_ROOT" = "$TARGET" ]; then
                continue
        fi

        STAT="$(stat --format "%A" "$INSTALL_ROOT/$TARGET")"

        if [ "$(echo "$STAT" | grep "^-.*x")" = "" ]; then
                continue
        fi

        DTSTAMP="$(stat --format "%y" "$INSTALL_ROOT/$TARGET" | awk '{print $1 " " $2}' | sed -E 's/(:[0-9]+)\.[0-9]+/\1/g')"

	CHECKSUM="$(cksum "$INSTALL_ROOT/$TARGET" | awk '{print $1}')"

        ELF_COMMENTS="$(readelf --string-dump=.comment $INSTALL_ROOT/$TARGET 2>/dev/null)"
        if [ $? -ne 0 ]; then
                IS_PV="-not elf-"
		SHA="-------"
        else
                if [ "$(echo "$ELF_COMMENTS" | grep "\-PV\-")" = "" ]; then
                        IS_PV="-vanilla-"
			SHA="-------"
                else
                        IS_PV="scrambled"
			SHA="$(echo "$ELF_COMMENTS" | awk -F'(' '{print $2}' | awk -F')' '{print $1}' | awk -F'-' '{print $3}')"
                fi
        fi

        printf "[%s] %s %s %-11s %s  %s\n" "$IS_PV" "$SHA" "$STAT" "$CHECKSUM" "$DTSTAMP" "$line"
done
