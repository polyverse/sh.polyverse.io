#!/bin/sh

which wget 2>&1 > /dev/null
if [ $? -ne 0 ]; then
	echo "Please install wget."
	exit 1
fi

if [ $# -eq 0 ]; then
	SCRIPT_LOCATION=`mktemp`
	wget -qO $SCRIPT_LOCATION https://raw.githubusercontent.com/polyverse/plv/master/scripts/help
	sh $SCRIPT_LOCATION
fi
