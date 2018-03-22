#!/bin/sh

################################################################################

################################################################################

if [ $(id -u) -ne 0 ]; then
	echo "This script must be run as root. Please try running this again as a sudo or root user." 1>&2
	exit 1
fi

which apt 2>&1 > /dev/null
if [ $? -ne 0 ]; then
	echo "apt not installed. This script is for apt-based Linux distros. Exiting..."	
	exit 1
fi

if [ ! -f /var/lib/dpkg/status ]; then
	echo "Error: /var/lib/dpkg/status not found. Exiting..."
	exit 1
fi

#
#  func getPolyverseRecord(<package_name>, <package_version>) int
#
#  Function calls 'apt-cache show <package_name>' (which returns records from all the indexes
#  that contain that package) and then parses out the metadata block that came from the
#  Polyverse repo. The record is written to stdout so the caller must capture it. The function
#  returns 0 if successful.
#
getPolyverseRecord() {
	PKG="$1"
	VER="$2"

	# return code is non-zero by default
	RETURN_CODE=1

	if [ "$PKG" = "" ] || [ "$VER" = "" ]; then
		echo "Error: empty parameter passed to getPolyverseRecord. [PKG='$PKG', VER='$VER']"
		return 1
	fi

	apt-cache show $PKG 2> /dev/null > $PKG.tmp
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ]; then
		return 1
	fi

	# csplit will create files xx00, xx01, etc. for each block separated by a blank line
	csplit $PKG.tmp '/^$/' "{*}" > /dev/null

	for record in $(ls xx?? | xargs); do
		# metadata from Polyverse contains SHA512: entry; official repo does not.
		PV_FINGERPRINT="$(cat $record | grep SHA512:)"
		# there could be multiple PV records, so make sure the version info matches
		if [ "$PV_FINGERPRINT" != "" ] && [ "$(cat $record | grep $VER)" != "" ]; then
			# sometimes a record has a leading/trailing blank line. trim this.
			# TO DO: our indexer occassionally is inserting a locale discriminant. this should be fixed in our indexer.
			cat $record | sed '/^\s*$/d' | sed 's/^Description-en:/Description:/g'
			RETURN_CODE=0
			break
		fi
	done

	# clean-up
	rm xx?? 2>/dev/null || true 
	rm $PKG.tmp

	return $RETURN_CODE
}

echo "Running 'apt update'..."
RESULT="$(apt update 2>&1)"

# All packages are up to date.

if [ "$(echo "$RESULT" | grep "All packages are up to date.")" != "" ]; then
	UP_TO_DATE="true"
fi

if [ "$(echo "$RESULT" | grep repo.polyverse.io)" != "" ]; then
	POLYMORPHIC_LINUX_INSTALLED="true"
fi

if [ "$UP_TO_DATE" != "true" ] && [ "$POLYMORPHIC_LINUX_INSTALLED" != "true" ]; then
	echo "Looks like you have some updates/upgrades to install before installing Polymorphic Linux. Please run the following command:"
	echo ""
	echo "  sudo apt update -y && sudo apt upgrade -y"
	echo ""
	exit 100
fi

if [ "$UP_TO_DATE" = "true" ] && [ "$POLYMORPHIC_LINUX_INSTALLED" != "true" ]; then
        echo "Your system is ready to install Polymorphic Linux. Install with the following command:"
        echo ""
        echo "  curl https://repo.polyverse.io/install.sh | sudo sh -s <authkey>"
        echo ""
        exit 200
fi

if [ "$UP_TO_DATE" = "true" ] && [ "$POLYMORPHIC_LINUX_INSTALLED" = "true" ]; then
	echo "Everything looks great! If you haven't already, you can re-install all your packages with the following command:"
	echo ""
	echo "  sudo apt install -y --reinstall \$(dpkg --get-selections | awk '{print \$1}')"
	echo ""
	exit 300
fi

# at this point, UP_TO_DATE != true and POLYMORPHIC_LINUX_INSTALLED = true

if [ ! -f /var/lib/dpkg/status.bak ]; then
        echo "Creating backup /var/lib/dpkg/status.bak..."
        cp /var/lib/dpkg/status /var/lib/dpkg/status.bak
else
        echo "Backup file /var/lib/dpkg/status.bak already exists. Not creating new backup."
fi

# remove working file if left-over from a previous run.
rm /var/lib/dpkg/status.tmp 2>/dev/null || true

echo "Getting packages marked for upgrade..."
UPGRADE_LIST="$(apt list --installed 2>/dev/null | grep upgradable | awk -F/ '{print $1}')"

FIXED_COUNT=0
SKIPPED_COUNT=0

FIX=""
CURRENT_RECORD=""
# process /var/lib/dpkg/status line-by-line
echo "Processing /var/lib/dpkg/status..."
while IFS= read -r line
do
	# new record always starts with "Package:"
	if [ "$(echo $line | grep ^Package:)" != "" ]; then
		PACKAGE_NAME="$(echo $line | awk '{print $2}')"
		# is this package record one we need to fix?
		if [ "$(echo "$UPGRADE_LIST" | grep ^$PACKAGE_NAME\$)" != "" ]; then
			FIX="true"
		fi
		printf "."
	fi

	# blank line means new record, so flush the previous record to the working file
	if [ "$line" = "" ]; then
		RETURN_CODE=0
		if [ "$FIX" = "true" ]; then
			PACKAGE_RECORD="$(getPolyverseRecord $PACKAGE_NAME $PACKAGE_VERSION)"
			RETURN_CODE=$?
		fi

		if [ "$FIX" = "true" ] && [ $RETURN_CODE -eq 0 ] && [ "$PACKAGE_STATUS" != "" ]; then
			FIXED_COUNT=$((FIXED_COUNT+1))
			# there's a bunch of fields in the index's metadata that need to be removed before being transferred to /var/lib/dpkg/status
			CURRENT_RECORD="$(echo "$PACKAGE_RECORD" | grep -v "^Package:" | grep -v "^Size:" | grep -v "^Filename:" | grep -v "^SHA" | grep -v "^Description-md5:")"
			CURRENT_RECORD="Package: $PACKAGE_NAME\n$CURRENT_RECORD\nStatus: $PACKAGE_STATUS"
		else
			SKIPPED_COUNT=$((SKIPPED_COUNT+1))
		fi
		echo "$CURRENT_RECORD" | sed '/^\s*$/d' >> /var/lib/dpkg/status.tmp	
		echo "" >> /var/lib/dpkg/status.tmp

		# reset variables
		FIX=""
		CURRENT_RECORD=""
	else
		CURRENT_RECORD="$CURRENT_RECORD\n$line"
	fi

	if [ "$(echo $line | grep ^Status:)" != "" ]; then
		PACKAGE_STATUS="$(echo $line | awk -F: '{print $2}' | xargs)"
	fi

	if [ "$(echo $line | grep ^Version:)" != "" ]; then
		PACKAGE_VERSION="$(echo $line | awk '{print $2}')"
	fi
done < "/var/lib/dpkg/status"

echo "\nFixed: $FIXED_COUNT, Skipped: $SKIPPED_COUNT"

echo "Moving working file to /var/lib/dpkg/status"
mv /var/lib/dpkg/status.tmp /var/lib/dpkg/status
