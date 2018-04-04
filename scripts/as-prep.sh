#!/bin/sh

GATEWAY_IP="52.42.103.75"

SCRAMBLED_JRE_LOCATION="/opt.pv/polyverse_jre"

ARCMC27PV_JRE_LOCATIONS="/opt/arcsight/current/local/jre"
ESM611PV_JRE_LOCATIONS="/opt.pv/arcsight/logger/current/local/jre /opt.pv/arcsight/manager/jre"
LOGGER65PV_JRE_LOCATIONS="/opt/current/arcsight/connector/current/jre /opt/current/local/jre"
SCONNHOSTPV_JRE_LOCATIONS="/opt/smartconnectors/syslog/current/jre /opt/smartconnectors/LinuxAudit/current/jre /opt/arcsight/connectors/windows/current/jre /opt/arcsight/connectors/netevents/current/jre /opt/arcsight/connectors/nix-events/current/jre /opt/arcsight/connectors/syslog-gen/current/jre"

usage() {
cat >&2 <<-EOF

Usage:

  plv as-prep <authkey> <node_id> <node_role>

Node Roles: esm611pv | arcmc27pv | logger65pv | sconnhostpv

EOF
}

STOPPED_SERVICES="false"
stopServices() {
	if [ $STOPPED_SERVICES ]; then
		return
	fi

	eval "$SERVICE_CMD stop"

	STOPPED_SERVICES="true"
	return 0
}

startServices() {
	if [ $STOPPED_SERVICES ]; then
		eval "$SERVICE_CMD start"
	fi

	STOPPED_SERVICES="false"
	return 0
}

if [ $# -lt 3 ]; then
	usage
	exit 1
fi

AUTHKEY="$1"
NODEID="$2"
NODEROLE="$3"

shift; shift; shift

PROBLEM_DETECTED="false"

while (( $# )) ; do
        case $1 in
                --fix)
                        FIX_PROBLEMS="true"
                        ;;
		--reinstall)
			FIX_REINSTALL="true"
			;;
		*)
			echo "error: unknown argument '$1'."
			exit 1
	esac
	shift
done

echo "Checking setup..."
echo

case $NODEROLE in
        esm611pv)
                SERVICE_CMD="/etc/init.d/arcsight_services"

		for JRE_LOCATION in $ESM611PV_JRE_LOCATIONS; do
			LS_OUTPUT="$(ls -l $JRE_LOCATION 2>/dev/null)"
			if [ "$(echo "$LS_OUTPUT" | grep polyverse_jre)" = "" ]; then
				FIX_JRE_SYMLINKS="true"
				PROBLEM_DETECTED="true"
				echo "[FAIL] $JRE_LOCATION not symlinked to /opt.pv/polyverse_jre."
			else
				echo "[PASS] $JRE_LOCATION --> /opt.pv/polyverse_jre"
			fi
		done
                ;;
        arcmc27pv)
                SERVICE_CMD="/etc/rc.d/init.d/arcsight_arcmc"

                for JRE_LOCATION in $ARCMC27PV_JRE_LOCATIONS; do
                        LS_OUTPUT="$(ls -l $JRE_LOCATION 2>/dev/null)"
                        if [ "$(echo "$LS_OUTPUT" | grep polyverse_jre)" = "" ]; then
                                FIX_JRE_SYMLINKS="true"
				PROBLEM_DETECTED="true"
                                echo "[FAIL] $JRE_LOCATION not symlinked to /opt.pv/polyverse_jre."
                        else
                                echo "[PASS] $JRE_LOCATION --> /opt.pv/polyverse_jre"
                        fi
                done
                ;;
        logger65pv)
                SERVICE_CMD="/etc/rc.d/init.d/arcsight_logger"

                for JRE_LOCATION in $LOGGER65PV_JRE_LOCATIONS; do
                        LS_OUTPUT="$(ls -l $JRE_LOCATION 2>/dev/null)"
                        if [ "$(echo "$LS_OUTPUT" | grep polyverse_jre)" = "" ]; then
                                FIX_JRE_SYMLINKS="true"
				PROBLEM_DETECTED="true"
                                echo "[FAIL] $JRE_LOCATION not symlinked to /opt.pv/polyverse_jre."
                        else
                                echo "[PASS] $JRE_LOCATION --> /opt.pv/polyverse_jre"
                        fi
                done
                ;;
        sconnhostpv)
                SERVICE_CMD=""

                for JRE_LOCATION in $SCONNHOSTPV_JRE_LOCATIONS; do
                        LS_OUTPUT="$(ls -l $JRE_LOCATION 2>/dev/null)"
                        if [ "$(echo "$LS_OUTPUT" | grep polyverse_jre)" = "" ]; then
                                FIX_JRE_SYMLINKS="true"
				PROBLEM_DETECTED="true"
                                echo "[FAIL] $JRE_LOCATION not symlinked to /opt.pv/polyverse_jre."
                        else
                                echo "[PASS] $JRE_LOCATION --> /opt.pv/polyverse_jre"
                        fi
                done
                ;;
        docker)
                SERVICE_CMD=""
                ;;
        *)
                echo "Error: unknown node_role '$NODEROLE'. Exiting..."
                exit 1
esac

if [ "$(cat /etc/hosts | grep "repo.polyverse.io")" = "" ]; then
	FIX_ETC_HOSTS="true"
	PROBLEM_DETECTED="true"
	echo "[FAIL] Missing repo.polyvrse.io entry in /etc/hosts..."
else
	echo "[PASS] repo.polyverse.io entry in /etc/hosts."
fi

if [ ! -f /etc/yum.repos.d/polyverse.repo ]; then
	FIX_POLY_INSTALL="true"
	PROBLEM_DETECTED="true"
	echo "[FAIL] Polymorphic Linux not installed."
else
	echo "[PASS] Polymorphic Linux repo file installed."
fi

if [ ! -d /opt.old ]; then
	FIX_BACKUP_OPT="true"
	PROBLEM_DETECTED="true"
	echo "[FAIL] /opt folder is not backed-up."
else
	echo "[PASS] /opt.old folder exists, meaning /opt has been backed-up."
fi

if [ "$(stat --format=%F /opt)" != "symbolic link" ]; then
	FIX_MISSING_SYMLINK="true"
	PROBLEM_DETECTED="true"
	echo "[FAIL] /opt is not a symbolic link: '$(stat --format=%F /opt)'"
else
	echo "[PASS] /opt is a symbolic link"
fi

LS_OUTPUT="$(ls -l /opt)"
if [ "$(echo $LS_OUTPUT | grep opt.pv)" = "" ]; then
	FIX_WRONG_SYMLINK="true"
	PROBLEM_DETECTED="true"
	echo "[FAIL] /opt is not correct: $LS_OUTPUT"
else
	echo "[PASS] /opt points to /opt.pv"
fi

if [ ! -d /opt/polyverse_jre ]; then
        FIX_MISSING_JDK="true"
	PROBLEM_DETECTED="true"
        echo "[FAIL] missing scrambled JDK folder at /opt/jre."
else
        echo "[PASS] scrambled JDK installed at /opt/jre."
fi

if [ ! $FIX_PROBLEMS ]; then
  exit 0
fi

echo "fixing problems..."

###
# FIX PROBLEMS
###

if [ $FIX_ETC_HOSTS ]; then
	if [ "$(cat /etc/hosts | grep "repo.polyverse.io")" = "" ]; then
		echo "Fixing... adding repo.polyverse.io /etc/hosts entry"
		echo "$GATEWAY_IP repo.polyverse.io" >> /etc/hosts
	fi
fi

if [ $FIX_BACKUP_OPT ]; then
	stopServices

	CMD="cp -pR /opt /opt.old"
	echo "+ $CMD"
	eval "$CMD"

	CMD="mv opt opt.pv"
	echo "+ $CMD"
	eval "$CMD"

	CMD="ln -s opt.pv opt"
	echo "+ $CMD"
	eval "$CMD"
fi

if [ $FIX_MISSING_SYMLINK ] || [ $FIX_WRONG_SYMLINK ]; then
	echo "*********** NOT YET IMPLEMENTED. NEED TO DO BY HAND. ***********"
fi

if [ $FIX_JRE_SYMLINKS ]; then
	stopServices

	for JRE_LOCATION in $ESM611PV_JRE_LOCATIONS; do
        	LS_OUTPUT="$(ls -l $JRE_LOCATION 2>/dev/null)"
		if [ "$(echo "$LS_OUTPUT" | grep polyverse_jre)" = "" ]; then
			STAT_OUTPUT="$(stat --format=%F $JRE_LOCATION)"
			if [ "$STAT_OUTPUT" = "symbolic link" ]; then
				CMD="rm -f $JRE_LOCATION"
				echo "+ $CMD"
				eval "$CMD"

				CMD="ln -s $SCRAMBLED_JRE_LOCATION $JRE_LOCATION"
				echo "+ $CMD"
				eval "$CMD"
			else
				CMD="mv $JRE_LOCATION $JRE_LOCATION.old"
				echo "+ $CMD"
				eval "$CMD"

				CMD="ln -s $SCRAMBLED_JRE_LOCATION $JRE_LOCATION"
				echo "+ $CMD"
				eval "$CMD"
			fi
		fi
	done
fi

if [ $FIX_POLY_INSTALL ] || [ $FIX_REINSTALL ]; then
	stopServices

	CMD="curl https://repo.polyverse.io/install.sh | sh -s $AUTHKEY $NODEID"
	echo "+ $CMD"
	eval "$CMD"

	CMD="yum reinstall -y \*"
	echo "+ $CMD"
	eval "$CMD"
fi

if [ "$SERVICE_CMD" != "" ]; then
	eval "$SERVICE_CMD status"
fi
