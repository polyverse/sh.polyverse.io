#!/bin/sh

GATEWAY_IP="52.42.103.75"

usage() {
cat >&2 <<-EOF

Usage:

  plv as-prep <authkey> <node_id> <node_role>

Node Roles: esm611pv | arcmc27pv | logger65pv | sconnhostpv

EOF
}

if [ $# -ne 3 ]; then
	usage
	exit 1
fi

AUTHKEY="$1"
NODEID="$2"
NODEROLE="$3"

if [ ! -d /opt.old ]; then
	echo "Backup: creating a copy of /opt to /opt.old..."
	cp -R /opt /opt.old
else
	echo "Backup: /opt.old already exists. Skipping."
fi

echo "Creating /opt/polyverse/nodeid..."
mkdir -p /opt/polyverse
echo $NODEID > /opt/polyverse/nodeid

case $NODEROLE in
	esm611pv)
		SERVICE_CMD="/etc/init.d/arcsight_services"
		;;
	arcmc27pv)
		SERVICE_CMD="/etc/rc.d/init.d/arcsight_arcmc"
		;;
	logger65pv)
		SERVICE_CMD="/etc/rc.d/init.d/arcsight_logger"
		;;
	sconnhostpv)
		SERVICE_CMD=""
		;;
	docker)
		SERVICE_CMD=""
		;;
	*)
		echo "Error: unknown node_role '$NODEROLE'. Exiting..."
		exit 1
esac
echo $NODEROLE > /opt/polyverse/noderole

if [ "$(cat /etc/hosts | grep "repo.polyverse.io")" = "" ]; then
	echo "Dedicated BigBang stack: adding /etc/hosts entry..."
	echo "$GATEWAY_IP repo.polyverse.io" >> /etc/hosts
else
	echo "Dedicated BigBang stack: /etc/hosts entry already exists. Skipping."
fi

if [ ! -f /etc/yum.repos.d/polyverse.repo ]; then
	if [ "$SERVICE_CMD" != "" ]; then
		eval "$SERVICE_CMD stop"
		if [ $? -ne 0 ]; then
			echo "Error: '$SERVICE_CMD stop' failed. Exiting..."
			exit 1
		fi
	fi
	echo "Polymorphic Linux: installing..."
	curl https://repo.polyverse.io/install.sh | sh -s $AUTHKEY $NODEID
	if [ $? -ne 0 ]; then
		echo "Encountered error. Exiting..."
		exit 1
	fi
	if [ "$SERVICE_CMD" != "" ]; then
		eval "$SERVICE_CMD start"
		if [ $? -ne 0 ]; then
			echo "Warning: '$SERVICE_CMD start' failed."
		fi
	fi
else
	echo "Polymorphic Linux: already installed. Skipping."
fi
if [ "$SERVICE_CMD" != "" ]; then
	eval "$SERVICE_CMD status"
fi
