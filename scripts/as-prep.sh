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

# originally has an /opt folder. backup /opt -> /opt.old
# working copy is called /opt.pv, so move /opt -> /opt.pv
# and then create a symlink /opt -> /opt.pv.
# if something fails, stop service, change symlink to /opt -> /opt.old
# and start the service again.
if [ ! -d /opt.old ]; then
	echo "Backup: creating a copy of /opt to /opt.old..."
	cp -pR /opt /opt.old
	mv opt opt.pv
	ln -s opt.pv opt
else
	echo "Backup: /opt.old already exists. Skipping."
fi


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

echo "Checking setup..."

if [ "$(cat /etc/hosts | grep "repo.polyverse.io")" = "" ]; then
	FIX_ETC_HOSTS="true"
	echo "--> Missing repo.polyvrse.io entry in /etc/hosts..."
else
	echo "--> [OK] repo.polyverse.io entry in /etc/hosts.
fi

if [ ! -f /etc/yum.repos.d/polyverse.repo ]; then
	FIX_POLY_INSTALL="true"
	echo "--> Polymorphic Linux not installed."
else
	echo "--> [OK] Polymorphic Linux repo file installed."
fi

if [ ! -d /opt.old ]; then
	FIX_BACKUP_OPT="true"
	echo "--> /opt folder is not backed-up."
else
	echo "--> [OK] /opt.old folder exists, meaning /opt has been backed-up."
fi


if [ "$(stat --format=%F /opt)" != "symbolic link" ]; then
	FIX_MISSING_SYMLINK="true"
	echo "--> /opt is not a symbolic link: '$(stat --format=%F /opt)'"
else
	echo "--> [OK] /opt is a symbolic link
fi

LS_OUTPUT="$(ls -l /opt)"
if [ "$(echo $LS_OUTPUT | grep opt.pv)" = "" ]; then
	FIX_WRONG_SYMLINK="true"
	echo "--> /opt is not correct: $LS_OUTPUT"
else
	echo "[OK] /opt --> /opt.pv"
fi

read -p "Press enter to continue or Ctrl+C to exit."
exit

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
	yum reinstall -y \*
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
