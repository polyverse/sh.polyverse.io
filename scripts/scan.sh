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

        DTSTAMP="$(stat --format "%y" "$INSTALL_ROOT/$TARGET")"

        ELF_COMMENTS="$(readelf --string-dump=.comment $INSTALL_ROOT/$TARGET 2>/dev/null)"
        if [ $? -ne 0 ]; then
                IS_PV="-not elf-"
        else
                if [ "$(echo "$ELF_COMMENTS" | grep "\-PV\-")" = "" ]; then
                        IS_PV="-vanilla-"
                else
                        IS_PV="scrambled"
                fi
        fi

        printf "[%s] %s %s %s\n" "$IS_PV" "$STAT" "$DTSTAMP" "$line"
done
