#!/bin/sh

display_reinstall_cmd() {
  echo
  echo "@@@@@   @@@@@@@@"
  echo "@@@@@   @@@@@@@@@@@@"
  echo "@@@@@   @@@@@@@@@@@@@@"
  echo "              @@@@@@@@"
  echo "@@@@@           @@@@@@@"
  echo "@@@@@                       @@@@@@@@@@@@      @@@@@      @@@@@          @@@  @@@@@          @@@@ @@@@@@@@@@@@@@  @@@@@@@@@@@@      @@@@@@@@@@    @@@@@@@@@@@@@@"
  echo "               @@@@@@@   @@@@@        @@@@    @@@@@       @@@@@       @@@@    @@@@@        @@@@  @@@@@           @@@@    @@@@@@  @@@@      @@@@  @@@@@"
  echo "@@@@@   @@@@@@@@@@@@@@  @@@@@          @@@@@  @@@@@         @@@@@    @@@       @@@@@      @@@@   @@@@@           @@@@     @@@@@  @@@@@           @@@@@"
  echo "@@@@@   @@@@@@@@@@@@   @@@@@@          @@@@@  @@@@@          @@@@@ @@@@         @@@@@     @@@    @@@@@           @@@@    @@@@@    @@@@@@         @@@@@"
  echo "@@@@@   @@@@@@@@@@     @@@@@           @@@@@  @@@@@           @@@@@@@            @@@@@   @@@     @@@@@@@@@@@@    @@@@@@@@@@@        @@@@@@@@     @@@@@@@@@@@@@"
  echo "                       @@@@@@          @@@@@  @@@@@             @@@@              @@@@@ @@@      @@@@@           @@@@  @@@@@            @@@@@@@  @@@@@"
  echo "@@@@@                   @@@@@          @@@@@  @@@@@             @@@@              @@@@@@@@       @@@@@           @@@@   @@@@@             @@@@@  @@@@@"
  echo "@@@@@                    @@@@@        @@@@    @@@@@             @@@@                @@@@@        @@@@@           @@@@     @@@@@  @@@@      @@@@  @@@@@"
  echo "@@@@@                       @@@@@@@@@@@@      @@@@@@@@@@@@@@    @@@@                @@@@         @@@@@@@@@@@@@@  @@@@      @@@@@   @@@@@@@@@@@   @@@@@@@@@@@@@@"
  echo
  echo
  echo
  echo "Polyverse is now your preferred repo! From this point forward, any package you install (or re-install) will be secured by Polyverse."
  echo
  echo "More information is available at http://info.polyverse.io/polymorphic-linux-cheetsheet. If you have any questions, you can reach us at support@polyverse.io"
  echo
}

apk_install() {
	FILE='/etc/apk/repositories'

	curl https://repo.polyverse.io/config/apk/3/key -o "/etc/apk/keys/support@polyverse.io-5992017d.rsa.pub"

	# make sure the default repo file exists
	if [ ! -f "$FILE" ]; then
		echo "The default repo file '$FILE' is missing. This is unexpected, so exiting..."
		exit 1
	fi

	# create a backup file
	if [ ! -f "${FILE}.pvbak" ]; then
		echo "Backing up $FILE to ${FILE}.pvbak..."
		cp $FILE ${FILE}.pvbak
		if [ $? -ne 0 ]; then
			echo "Unable to create backup file. This is unexpected, so exiting..."
			exit 1
		fi
	else
		echo "Backup file ${FILE}.pvbak already exists, so we'll leave it alone."
	fi

	# check if there's a previous repo.polyverse.io entry in /etc/apk/repositories file. support script being run multiple times.
	RESULT="$(cat $FILE | grep -i polyverse)"
	if [ ! -z "$RESULT" ]; then
		echo "Detected previous entry for repo.poyverse.io. Restoring from ${FILE}.pvbak..."
		cp ${FILE}.pvbak ${FILE}
	fi
	
	# Update the repositories file
	ESCAPED_TEXT="$(echo "$1" | sed 's/\//\\\//g' | sed 's/$/\\n/' | tr -d '\n')"
	sed -i "1s/^/$ESCAPED_TEXT/" $FILE
	if [ $? -ne 0 ]; then
		echo "The Polyverse repo did not install correctly. Restoring backup. Please contact us at support@polyverse.io."
		mv ${FILE}.pvbak ${FILE}
		if [ $? -ne 0 ]; then
			"Encountered an issue moving the file '${FILE}.pvbak' to '$FILE'. Please perform this manually to complete the rollback."
		fi

		exit 1
	fi

	display_reinstall_cmd "sed -n -i '/polyverse.io/p' /etc/apk/repositories && apk upgrade --update-cache --available"
}

apk_uninstall() {
	FILE='/etc/apk/repositories'

	# make sure the default repo file exists
	if [ ! -f "$FILE" ]; then
		echo "The default repo file '$FILE' is missing. This is unexpected, so exiting..."
		exit 1
	fi

	# missing backup file
	if [ ! -f "${FILE}.pvbak" ]; then
		echo "Can't find the backup file ${FILE}.pvbak. You can manually uninstall by removing all the lines with 'polyverse.io' from the file '$FILE'."
		exit 1
	fi

	echo "Restoring original version of '$FILE'..."
	mv ${FILE}.pvbak $FILE
	if [ $? -ne 0 ]; then
		echo "Encountered an issue moving the file '${FILE}.pvbak' to '$FILE'. Please perform this manually to complete the uninstall."
		exit 1
	fi

	echo "Polyverse's Polymorphic Linux repo entries have been successfully removed. All future package installs/updates will come from the previously specified repos."
}

rpm_install() {
	FILE='/etc/yum.repos.d/polyverse.repo'

	curl https://repo.polyverse.io/config/rpm/7/key -o "/etc/pki/RPM-GPG-KEY-Polyverse"

	printf "$1" > $FILE

	# check that the file was installed properly
	if [ ! -f "$FILE" ]; then
		echo "The Polyverse repo did not install correctly, please try again or contact Polyverse support. Exiting..."
		exit 1
	fi

	display_reinstall_cmd "yum reinstall -y \*"
}

rpm_uninstall() {
	FILE='/etc/yum.repos.d/polyverse.repo'

	if [ ! -f "$FILE" ]; then
		echo "Can't find the repo file '$FILE'. It does not appear that Polyverse's Polymorphic Linux is installed."
		exit 1
	fi

	rm $FILE
	if [ $? -ne 0 ]; then
		echo "Encountered an issue removing the file '$FILE'. Please remove it manually."
		exit 1
	fi

	echo "Polyverse's Polymorphic Linux repo file has successfully been uninstalled. All future package installs/updates will come from the previously specified repos."
}

deb_install() {
	FILE='/etc/apt/sources.list'

	# make sure the default repo file exists
	if [ ! -f "$FILE" ]; then
		echo "The default repo file '$FILE' is missing. This is unexpected, so exiting..."
		exit 1
	fi

	# create a backup file
	if [ ! -f "${FILE}.pvbak" ]; then
		echo "Backing up $FILE to ${FILE}.pvbak..."
		cp $FILE ${FILE}.pvbak
		if [ $? -ne 0 ]; then
			echo "Unable to create backup file. This is unexpected, so exiting..."
			exit 1
		fi
	else
		echo "Backup file ${FILE}.pvbak already exists, so we'll leave it alone."
	fi

	echo "Updating apt cache to insure we get the latest versions."
	apt -qq update

	echo "Installing apt-transport-https to support the https repo endpoint."
	apt -qq install apt-transport-https -y

	echo "Installing the Polyverse public repo key."
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 067A5E87

	# check if there's a previous repo.polyverse.io entry in /etc/apt/sources.list file. support script being run multiple times.
	RESULT="$(cat /etc/apt/sources.list | grep -i polyverse)"
	if [ ! -z "$RESULT" ]; then
		echo "Detected previous entry for repo.poyverse.io. Restoring from ${FILE}.pvbak..."
		cp ${FILE}.pvbak ${FILE}
	fi

	# Update the sources.list file
	ESCAPED_TEXT="$(echo "$1" | sed 's/\//\\\//g' | sed 's/$/\\n/' | tr -d '\n')"
	sed -i "1s/^/$ESCAPED_TEXT/" $FILE
	if [ $? -ne 0 ]; then
		echo "The Polyverse repo did not install correctly. Restoring backup. Please contact us at support@polyverse.io."
		mv ${FILE}.pvbak ${FILE}
		if [ $? -ne 0 ]; then
			"Encountered an issue moving the file '${FILE}.pvbak' to '$FILE'. Please perform this manually to complete the rollback."
		fi
		exit 1
	fi

	display_reinstall_cmd "apt-get update && apt-get -y --allow-change-held-packages install --reinstall \$(dpkg --get-selections | awk '{print \$1}')"
}

deb_uninstall() {
        FILE='/etc/apt/sources.list'

	if [ ! -f "${FILE}.pvbak" ]; then
		echo "Can't find the backup file ${FILE}.pvbak. You can manually uninstall by removing all the lines with 'polyverse.io' from the file '$FILE'."
	exit 1
	fi

	echo "Restoring original version of '$FILE'..."
	mv ${FILE}.pvbak $FILE
	if [ $? -ne 0 ]; then
		echo "Encountered an issue moving the file '${FILE}.pvbak' to '$FILE'. Please perform this manually to complete the uninstall."
		exit 1
	fi

	echo "Polyverse's Polymorphic Linux repo entries have been successfully removed. All future package installs/updates will come from the previously specified repos."
}

decode() {
	str="$1"
	str="$(echo $str | sed 's/++/ /g')"
	str="$(echo $str | sed 's/--/_/g')"
	str="$(echo $str | sed 's/\^\^/\//g')"
	echo "$str"
}

# Initialization
PFRACs=""
op="install"

while [ $# -gt 0 ]; do
	case "$1" in
		--add-component)
			shift
			PFRACs="$PFRACs $1"
			;;
		uninstall)
			op="uninstall"
			;;
		*)
			if [ -z "$AUTH_KEY" ]; then
				AUTH_KEY="$1"
			elif [ -z "$NODE_ID" ]; then
				NODE_ID="$1"
			else
				echo "Error: unexpected argument '$1'."
				exit 1
			fi
	esac
	shift
done

if [ $(id -u) -ne 0 ]; then
	echo "This script must be run as root. Please try running this again as a sudo or root user." 1>&2
	exit 1
fi

if [ "$op" = "install" ]; then
	if [ -z "$AUTH_KEY" ]; then
		echo "Usage: install.sh <authkey>|uninstall [<nodeid>] [<options>]"
		echo
		echo "Options:"
		echo "  --add-component <component_name>"
		exit 1
	fi

	if [ ! -f /usr/bin/curl ]; then
		echo "This script requires curl. Please install it and try running this again." 1>&2
		exit 1
	fi

	#if [ "$NODE_ID" = "" ]; then NODE_ID="$(hostname)"; fi
	if [ "$NODE_ID" = "" ]; then NODE_ID="$HOSTNAME"; fi
	if [ "$NODE_ID" = "" ]; then
		echo "Error: couldn't auto-generate a node id. Please re-run and explicitly provide a node_id value. Exiting..." >&2
		exit 1
	fi
fi

# make sure we're able to retrieve the distro release id (e.g., alpine, centos, ubuntu) and version id.
DISTRO=$(cat /etc/os-release 2>/dev/null | grep "^ID=" | cut -d '=' -f2 | tr -d '"')
RELEASE=$(cat /etc/os-release 2>/dev/null | grep "VERSION_ID=" | cut -d "=" -f2 | tr -d '"')
CODENAME=$(cat /etc/*-release 2>/dev/null | grep "^DISTRIB_CODENAME=" | cut -d '=' -f2 | tr -d '"')
ARCH="$(uname -m)"
if [ -z "$DISTRO" ] || [ -z "$RELEASE" ] || [ -z "$ARCH" ]; then
	echo "Could not determine Linux distro. DISTRO='$DISTRO', RELEASE='$RELEASE', ARCH='$ARCH'. Exiting..." >&2
 	exit 1
fi

case $DISTRO in
	alpine)
		# make 3.x vs 3.x.x
		RELEASE="$(echo $RELEASE | awk -F'.' '{print $1"."$2}')"

		PFRACs="$PFRACs alpine_apk_${RELEASE}_x86--64_main"
		PFRACs="$PFRACs alpine_apk_${RELEASE}_x86--64_community"

		install() {
			apk_install "$@"
		}
		uninstall() {
			apk_uninstall "$@"
		}
		;;
	centos | fedora)
		PFRACs="$PFRACs ${DISTRO}_rpm_${RELEASE}_x86--64_os"
		PFRACs="$PFRACs ${DISTRO}_rpm_${RELEASE}_x86--64_updates"

		install() {
			rpm_install "$@"
		}
		uninstall() {
			rpm_uninstall "$@"
		}
		;;
	ubuntu)
		PFRACs="$PFRACs ubuntu_deb_${CODENAME}_binary--amd64_main "
		#PFRACs="$PFRACs ubuntu_deb_${CODENAME}_binary--amd64_universe"
		PFRACs="$PFRACs ubuntu_deb_${CODENAME}-updates_binary--amd64_main"
		#PFRACs="$PFRACs ubuntu_deb_${CODENAME}-updates_binary--amd64_universe"
		PFRACs="$PFRACs ubuntu_deb_${CODENAME}-security_binary--amd64_main"

		install() {
			deb_install "$@"
		}
		uninstall() {
			deb_uninstall "$@"
		}
		;;
	*)
		echo "Distro '$DISTRO' not supported."
		exit 1
		;;
esac

if [ "$op" = "install" ]; then
	REPO_FILE_CONTENTS=""
	for PFRAC in $PFRACs
	do
		P="$(decode $(echo $PFRAC | awk -F'_' '{print $1}'))"
		F="$(decode $(echo $PFRAC | awk -F'_' '{print $2}'))"
		R="$(decode $(echo $PFRAC | awk -F'_' '{print $3}'))"
		A="$(decode $(echo $PFRAC | awk -F'_' '{print $4}'))"
		C="$(decode $(echo $PFRAC | awk -F'_' '{print $5}'))"

		URL="https://repo.polyverse.io/register?authKey=$AUTH_KEY&nodeID=$NODE_ID&distro=$DISTRO&project=$P&format=$F&release=$R&arch=$A&component=$C"
		echo "$URL"

		# 'wget --content-on-error -qO- "$URL"' doesn't work reliably across distros
		COMPONENT_FILE_PART="$(curl -s --insecure --fail "$URL")"
		EXIT_CODE=$?

		if [ $EXIT_CODE -ne 0 ]; then
			# can't get errror code and body at the same time, so need to fetch the error message
			RESULT="$(curl -s --insecure "$URL")"
			echo "Registration error: $RESULT"
			exit 1
		fi

		REPO_FILE_CONTENTS="${REPO_FILE_CONTENTS}${COMPONENT_FILE_PART}\n\n"
	done
fi

$op "$REPO_FILE_CONTENTS"