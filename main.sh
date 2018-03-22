#!/bin/sh

wget -V >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error: please install wget."
	exit 1
fi

if [ $# -eq 0 ] || [ "$1" = "help" ]; then
	wget -qO- --no-cache https://raw.githubusercontent.com/polyverse/plv/master/usage.txt
	exit 1
fi

_exit() {
	rm $SCRIPT 2>/dev/null || true
	exit $1
}

SCRIPT=`mktemp -t plv.XXX`
wget -qO $SCRIPT --no-cache https://raw.githubusercontent.com/polyverse/plv/master/scripts/$1.sh
if [ $? -ne 0 ]; then
	echo "Error: unknown subcommand '$1'."
	_exit
fi
sh $SCRIPT
_exit $?
