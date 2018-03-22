#!/bin/sh

# LOCAL_MODE makes development easier; otherwise, any change would require git commit/push to test.
# You must run plv from the git project repo's top folder to enable this mode.
LOCAL_MODE=false
if [ -d "scripts" ] && [ -f "plv" ]; then
        LOCAL_MODE=true
fi

if $LOCAL_MODE; then
	(>&2 echo '\033[0;34m'"(local mode)"'\033[0m' )

	USAGE_SOURCE="cat usage.txt"
	SCRIPT_SOURCE="cat scripts/$1.sh"
else
	# make sure wget is installed
	wget -V >/dev/null 2>&1
	if [ $? -ne 0 ]; then
        	echo "Error: please install wget."
        	exit 1
	fi

	USAGE_SOURCE="wget -qO- --no-cache https://raw.githubusercontent.com/polyverse/plv/master/usage.txt"
	SCRIPT_SOURCE="wget -qO- --no-cache https://raw.githubusercontent.com/polyverse/plv/master/scripts/$1.sh"
fi


if [ $# -eq 0 ] || [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        eval $USAGE_SOURCE
        exit 1
fi

# export variables that may be useful for downstream scripts.
export PLV_DISTRO=$(cat /etc/os-release 2>/dev/null | grep "^ID=" | cut -d '=' -f2 | tr -d '"')
export PLV_RELEASE=$(cat /etc/os-release 2>/dev/null | grep "VERSION_ID=" | cut -d "=" -f2 | tr -d '"')
export PLV_ARCH="$(uname -m)"

# retrieve the script source into a temp file
TEMPFILE=`mktemp -t pv.XXX`
CMD="eval \"$SCRIPT_SOURCE\" > $TEMPFILE"
(>&2 echo '\033[0;34m'"+ $CMD"'\033[0m' )
eval "$CMD" 2>/dev/null
if [ $? -ne 0 ]; then
	echo "Error: unsupported subcommand '$1'."
	exit 1
fi

CMD="cat $TEMPFILE | sh -s"
(>&2 echo '\033[0;34m'"+ $CMD"'\033[0m' )
eval "$CMD"
EXIT_CODE=$?

# remove the tempfile if the script executed successfully
if [ $EXIT_CODE -eq 0 ]; then
	CMD="rm $TEMPFILE"
	(>&2 echo '\033[0;34m'"+ $CMD > $TEMPFILE"'\033[0m' )
	eval "$CMD"
	exit 0
fi

exit $EXIT_CODE
