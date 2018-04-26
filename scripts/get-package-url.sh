#!/bin/sh

function apk_alpine() {
        (>&2 echo "error: support for alpine not yet implemented.")
        return 1
}

function deb_ubuntu() {
	(>&2 echo "error: support for ubuntu not yet implemented.")
	return 1
}

function rpm_fedora() {
	local FILENAME="$1"
	local RELEASE="$(echo $FILENAME | sed 's/.*fc\([0-9][0-9]\).*/\1/')"
	local FIRST_LETTER=${FILENAME:0:1}

	if [ -z "$RELEASE" ]; then
		(>&2 echo "error: unable to determine fedora release for '$FILENAME'.")
		return 1
	fi

	URLs=""
	URLs="$URLs http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/${RELEASE}/Everything/x86_64/os/Packages/${FIRST_LETTER}"
	URLs="$URLs http://download.fedoraproject.org/pub/archive/fedora/linux/updates/${RELEASE}/x86_64/Packages/${FIRST_LETTER}"

	return 0
}

function rpm_centos() {
	local RELEASES="6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0.1406 7.1.1503 7.2.1511 7.3.1611"

	URLs=""
	for RELEASE in $RELEASES; do
		URLs="$URLs http://vault.centos.org/${RELEASE}/os/x86_64/Packages"
		URLs="$URLs http://vault.centos.org/${RELEASE}/updates/x86_64/Packages"
	done

	URLs="$URLs http://mirror.centos.org/centos/7/os/x86_64/Packages"
	URLs="$URLs http://mirror.centos.org/centos/7/updates/x86_64/Packages"

	return 0
}

function get_format() {
	local FILENAME="$1"
	local FORMAT="${FILENAME##*.}"

	if [ "$FORMAT" != "rpm" ] && [ "$FORMAT" != "apk" ] && [ "$FORMAT" != "deb" ]; then
		(>&2 echo "error: unsupported type '$FORMAT'")
		return 1
	fi

	echo "$FORMAT"
	return 0
}

function get_project() {
	local FILENAME="$1"
	local FORMAT="$(get_format $FILENAME)"
	local PROJECT=""

	case $FORMAT in
		apk)
			PROJECT="alpine"
			;;
		deb)
			PROJECT="ubuntu"
			;;
		rpm)
			if [ ! -z "$(echo "$FILENAME" | tr "." "\n" | grep -e "fc[0-9][0-9]")" ]; then
				PROJECT="fedora"
			else
				PROJECT="centos"
			fi
			;;
		*)
			(>&2 echo "error: unable to determine project for type '$FORMAT'")
			return 1
	esac
	
	echo "$PROJECT"
	return 0		
}

function GetPackageURL() {
        local FILENAME="$1"

        for URL in $URLs; do
                if [ ! -z "$(curl -sI $URL/$FILENAME | grep "200 OK")" ]; then
                        echo "$URL/$FILENAME"
                        return 0
                fi
        done

        return 1
}

FORMAT="$(get_format $1)"
if [ $? -ne 0 ]; then exit 1; fi

PROJECT="$(get_project $1)"
if [ $? -ne 0 ]; then exit 1; fi

# call function called <format>_<project> to populate LOCS variable
${FORMAT}_${PROJECT} $1
if [ $? -ne 0 ]; then exit 1; fi

RESULT="$(GetPackageURL $1)"
if [ $? -ne 0 ]; then
	(>&2 echo "Not found.")
	exit 1
fi

# write the final result to stdout
echo "$RESULT"
exit 0
