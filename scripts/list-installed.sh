#!/bin/sh

apt_list() {
	INSTALLED="$(apt list --installed 2>/dev/null | tail -n +2 | awk -F/ '{print $1}')"
	TEMP_FILE=`mktemp`
	echo "TEMP_FILE=$TEMP_FILE"

	for PACKAGE in $INSTALLED; do
		POLICY="$(apt-cache policy $PACKAGE)"
		VERSION="$(echo "$POLICY" | grep Installed: | awk '{print $2}')"
		REPO_SOURCE="$(echo "$POLICY" | awk '/\*\*\*/,/100 /' | grep http | awk '{print $2}' | xargs | sed 's/ /,/g')"
		if [ "$REPO_SOURCE" = "" ]; then
			REPO_SOURCE="(local)"
		fi
		echo "$PACKAGE $VERSION $REPO_SOURCE" | tee -a $TEMP_FILE
	done

	PACKAGES_FROM_PV="$(cat $TEMP_FILE | grep repo.polyverse.io | wc -l)"
	TOTAL_PACKAGES="$(cat $TEMP_FILE | wc -l)"

	(>&2 echo "Packages from repo.polyverse.io: $PACKAGES_FROM_PV/$TOTAL_PACKAGES" )

	#rm $TEMP_FILE 2>/dev/null || true

	#apt-cache show bash
}

case $PLV_DISTRO in
	centos | fedora)
		LIST_FUNC="yum_list"
		;;
	ubuntu)
		LIST_FUNC="apt_list"
		;;
	*)
		exit 1
		;;
esac

eval "$LIST_FUNC"
