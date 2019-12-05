#!/bin/sh

if [ -z "$PV_BASE_URL" ]; then
	export PV_BASE_URL="https://repo-staging.polyverse.io/cli"
fi

PV_SHELL="sh"
if [ ! -z "$(echo $SHELL | grep bash)" ]; then
	PV_SHELL="bash"
fi

SUBCMD=""
while [ $# -gt 0 ] ; do
	case $1 in
		--help | help | -h)
			SUBCMD="cli"
			;;
		*)
			if [ -z "$SUBCMD" ]; then
				SUBCMD="$1"
			fi
			ARGS="$ARGS \"$1\""
	esac
	shift
done

if [ -z "$SUBCMD" ]; then
	SUBCMD="cli"
fi

curl -s --fail $PV_BASE_URL/$SUBCMD >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "error: unknown subcommand '$SUBCMD'."
	exit 1
fi

eval "curl -sS $PV_BASE_URL/$SUBCMD | $PV_SHELL -s $ARGS"
exit $?
