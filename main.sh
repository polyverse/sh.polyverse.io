#!/bin/sh

which wget 2>&1 > /dev/null
if [ $? -ne 0 ]; then
	echo "Error: please install wget."
	exit 1
fi

if [ $# -eq 0 ] || [ "$1" = "help" ]; then
	wget -qO- --no-cache https://raw.githubusercontent.com/polyverse/plv/master/usage.txt
	exit
fi

_exit() {
	rm $SCRIPT_LOCATION 2>/dev/null || true
	exit $1
}

SCRIPT_LOCATION=`mktemp`
wget -qO $SCRIPT_LOCATION --no-cache https://raw.githubusercontent.com/polyverse/plv/master/scripts/$1
if [ $? -ne 0 ]; then
	echo "Error: unknown subcommand '$1'."
	_exit
fi
sh $SCRIPT_LOCATION
_exit $?
