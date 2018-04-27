#!/bin/sh

if [ -z "$PV_BASE_URL" ]; then
	PV_BASE_URL="https://sh.polyverse.io"
fi

#******************************************************************************#
#                                 functions                                    #
#******************************************************************************#

usage_and_exit() {
	curl -s $PV_BASE_URL/usage.txt
	if [ $? -ne 0 ]; then
		echo "error: unable to curl '$PV_BASE_URL/usage.txt'."
	fi
	exit 1
}

precheck() {
	local CONTENT_LENGTH="$(curl -sI $1 | grep -i "content-length" | awk -F':' '{print $2}')"
	if [ "$CONTENT_LENGTH" != "" ] && [ "$CONTENT_LENGTH" != "0" ]; then
		return 0
	fi
	return 1
}

#******************************************************************************#
#                                    main                                      #
#******************************************************************************#

if [ $# -eq 0 ]; then
	usage_and_exit
fi

SUBCMD=""
while (( $# )) ; do
	case $1 in
		-h | --help | help)
			usage_and_exit
			;;
		*)
			if [ -z "$SUBCMD" ]; then
				SUBCMD="$1"
			fi
			ARGS="$ARGS \"$1\""
	esac
	shift
done

precheck "$PV_BASE_URL/scripts/$SUBCMD"
if [ $? -ne 0 ]; then
	echo "error: unrecognized subcommand '$SUBCMD'."
	exit 1
fi

eval "curl -s $PV_BASE_URL/scripts/$SUBCMD | sh -s $ARGS"
exit $?
