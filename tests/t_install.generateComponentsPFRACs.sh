#!/bin/bash

PV_DEFINE_INCLUDE="true"
source ../scripts/install
PV_DEFINE_INCLUDE=""

main() {
	EXIT_CODE=0

	assert centos rpm 6 x86_64 "kernel" "centos_rpm_6_x86--64_os-kernel centos_rpm_6_x86--64_updates-kernel"
	let EXIT_CODE=EXIT_CODE+$?

	assert centos rpm 7 x86_64 "kernel" "centos_rpm_7_x86--64_os-kernel centos_rpm_7_x86--64_updates-kernel"
	let EXIT_CODE=EXIT_CODE+$?

	RESULT="$(generateComponentsPFRACs ubuntu deb xenial amd64 "epel")"
	if [ $? -ne 0 ]; then
		echo "\"$RESULT\" [pass]"
	else
		echo "\"$RESULT\" [fail]"
		let EXIT_CODE=EXIT_CODE+1
	fi

	return $EXIT_CODE
}

assert() {
	_DISTRO="$1"
	_FORMAT="$2"
	_RELEASE="$3"
	_ARCH="$4"
	_COMPONENTS="$5"
	_PFRACs="$6"

	_RESULT="$(generateComponentsPFRACs ${_DISTRO} ${_FORMAT} ${_RELEASE} ${_ARCH} "${_COMPONENTS}")"
	if [ "${_RESULT}" == "${_PFRACs}" ]; then
		echo "generateComponentsPFRACs ${_DISTRO} ${_FORMAT} ${_RELEASE} ${_ARCH} \"${_COMPONENTS}\": \"$_RESULT\" [pass]"
	else
		echo "generateComponentsPFRACs ${_DISTRO} ${_FORMAT} ${_RELEASE} ${_ARCH} \"${_COMPONENTS}\": \"$_RESULT\" [fail]"
		return 1
	fi

	return 0
}

main "$@"
exit $?

