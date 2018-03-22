#!/bin/sh

# LOCAL_MODE is for local development/testing and for those who prefer to install this CLI via git clone.
LOCAL_MODE=false
if [ -d "scripts" ] && [ -f "plv" ]; then
        LOCAL_MODE=true
fi

if $LOCAL_MODE; then
	(>&2 echo "(local mode)" )

	USAGE_CMD="cat usage.txt"
	CMD="sh scripts/$1.sh"
else
	wget -V >/dev/null 2>&1
	if [ $? -ne 0 ]; then
        	echo "Error: please install wget."
        	exit 1
	fi

	USAGE_CMD="wget -qO- --no-cache https://raw.githubusercontent.com/polyverse/plv/master/usage.txt"
	CMD="wget -qO- --no-cache https://raw.githubusercontent.com/polyverse/plv/master/scripts/$1.sh | sh -s"
fi


if [ $# -eq 0 ] || [ "$1" = "help" ]; then
        eval $USAGE_CMD
        exit 1
fi

export PLV_DISTRO=$(cat /etc/os-release 2>/dev/null | grep "^ID=" | cut -d '=' -f2 | tr -d '"')
export PLV_RELEASE=$(cat /etc/os-release 2>/dev/null | grep "VERSION_ID=" | cut -d "=" -f2 | tr -d '"')
export PLV_ARCH="$(uname -m)"

echo "+ $CMD"
eval "$CMD"
exit $?
