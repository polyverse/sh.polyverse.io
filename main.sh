#!/bin/sh

which wget 2>&1 > /dev/null
if [ $? -ne 0 ]; then
	echo "Error: please install wget."
	exit 1
fi

if [ $# -eq 0 ]; then
	CMD="help"
else
	CMD="$1"
fi

_exit() {
	rm $SCRIPT_LOCATION 2>/dev/null || true
	exit $1
}

SCRIPT_LOCATION=`mktemp`
wget -qO $SCRIPT_LOCATION --no-cache https://raw.githubusercontent.com/polyverse/plv/master/scripts/$CMD
if [ $? -ne 0 ]; then
	echo "Error: unknown subcommand '$CMD'."
	_exit
fi
sh $SCRIPT_LOCATION
_exit $?
