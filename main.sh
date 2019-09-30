#!/bin/sh

if [ -z "$PV_BASE_URL" ]; then PV_BASE_URL="https://sh.polyverse.com"; fi

PV_SHELL="sh"
if [ ! -z "$(echo $SHELL | grep bash)" ]; then
	PV_SHELL="bash"
fi

#******************************************************************************#
#                                 functions                                    #
#******************************************************************************#

eval_or_exit() {
	CMD="$1"
        RESULT="$($CMD 2>&1)"
	EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
                (>&2 echo "error: '$CMD' failed with '$RESULT'.")
		exit $EXIT_CODE
        fi
        echo "$RESULT"
}

usage_and_exit() {
	eval_or_exit "curl -sS $PV_BASE_URL/usage.txt"
	exit 1
}

precheck() {
	# exit on hard curl failures (e.g., unsupported protocol)
	HTTP_RESPONSE="$(eval_or_exit "curl -sSI $1")"
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ]; then exit $EXIT_CODE; fi

	# 200 (specifically non-zero content-length) means script is found
	CONTENT_LENGTH="$(curl -sI $1 | grep -i content-length | awk -F':' '{print $2}')"
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ]; then exit $EXIT_CODE; fi

	if [ "$CONTENT_LENGTH" != "" ] && [ "$CONTENT_LENGTH" != "0" ]; then
		return 0
	fi

	return 1
}

#******************************************************************************#
#                                    main                                      #
#******************************************************************************#

if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "help" ]; then
	usage_and_exit
fi

SUBCMD=""
while [ $# -gt 0 ] ; do
	case $1 in
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
	echo "error: unknown subcommand '$SUBCMD'."
	exit 1
fi

eval "curl -sS $PV_BASE_URL/scripts/$SUBCMD | $PV_SHELL -s $ARGS"
exit $?
