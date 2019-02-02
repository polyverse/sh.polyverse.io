#!/bin/bash

PV_DEFINE_INCLUDE="true"
source ../scripts/install
PV_DEFINE_INCLUDE=""

main() {
	EXIT_CODE=0

	assert alpine apk 3.6 x86_64 "alpine_apk_3.6_x86--64_main alpine_apk_3.6_x86--64_community"
	let EXIT_CODE=EXIT_CODE+$?

	assert centos rpm 6 x86_64 "centos_rpm_6_x86--64_os centos_rpm_6_x86--64_updates"
	let EXIT_CODE=EXIT_CODE+$?

	assert centos rpm 7 x86_64 "centos_rpm_7_x86--64_os centos_rpm_7_x86--64_updates"
	let EXIT_CODE=EXIT_CODE+$?

	assert ubuntu deb xenial amd64 "ubuntu_deb_xenial_binary--amd64_main ubuntu_deb_xenial-updates_binary--amd64_main ubuntu_deb_xenial-security_binary--amd64_main"
	let EXIT_CODE=EXIT_CODE+$?

	RESULT="$(generateDefaultPFRACs foobar rpm 6 x86_64)"
	if [ $? -ne 0 ]; then
		echo "generateDefaultPFRACs foobar rpm 6 x86_64: \"$RESULT\" (expecting non-zero return value) [pass]"
	else
		echo "generateDefaultPFRACs foobar rpm 6 x86_64: \"$RESULT\" (expecting non-zero return value) [fail]"
		let EXIT_CODE=EXIT_CODE+1
	fi

	return $EXIT_CODE
}

assert() {
	_DISTRO="$1"
	_FORMAT="$2"
	_RELEASE="$3"
	_ARCH="$4"
	_PFRACs="$5"

	_RESULT="$(generateDefaultPFRACs ${_DISTRO} ${_FORMAT} ${_RELEASE} ${_ARCH})"
	if [ "${_RESULT}" == "${_PFRACs}" ]; then
		echo "generateDefaultPFRACs ${_DISTRO} ${_FORMAT} ${_RELEASE} ${_ARCH}: \"$_RESULT\" [pass]"
	else
		echo "generateDefaultPFRACs ${_DISTRO} ${_FORMAT} ${_RELEASE} ${_ARCH}: \"$_RESULT\" [fail]"
		return 1
	fi

	return 0
}

main "$@"
exit $?

