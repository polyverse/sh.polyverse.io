#!/bin/bash

PV_DEFINE_INCLUDE="true"
source ../scripts/install
PV_DEFINE_INCLUDE=""

main() {
	INFO=$(cat <<- EOM
		DISTRO=rhel
		RELEASE=6
		VERSION_ID=6.10
		ARCH=x86_64
		PACKAGE_MANAGER=yum
		FORMAT=rpm
		HOSTNAME="foo bar"
		KERNEL_NAME=Linux
		KERNEL_RELEASE=4.9.125-linuxkit
		EOM
	)

	EXIT_CODE=0

	echo "Test: $0..."

	assert "DISTRO" "rhel" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "RELEASE" "6" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "VERSION_ID" "6.10" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "ARCH" "x86_64" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "PACKAGE_MANAGER" "yum" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "FORMAT" "rpm" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	# tests the KEY="VALUE" style (double quotes to handle spaces in VALUE)
	assert "HOSTNAME" "foo bar" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "KERNEL_NAME" "Linux" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	assert "KERNEL_RELEASE" "4.9.125-linuxkit" "$INFO"
	let EXIT_CODE=EXIT_CODE+$?

	# test that parseInfo() fails properly
	RESULT="$(parseInfo "FOO" "$INFO")"
	if [ $? -ne 0 ]; then
		echo "Expecting error. Got: \"$RESULT\" [pass]"
	else
		echo "Expecting error. Got: \"$RESULT\" [fail]"
		let EXIT_CODE=EXIT_CODE+1
	fi

	return $EXIT_CODE
}

assert() {
	_KEY="$1"
	_VAL="$2"
	_INFO="$3"

	_RESULT="$(parseInfo "${_KEY}" "${_INFO}")"
	if [ $? -eq 0 ] && [ "$_RESULT" == "${_VAL}" ]; then
		echo "${_KEY}=${_RESULT} [pass]"
	else
		echo "${_KEY}=${_RESULT} [fail]"
		return 1
	fi

	return 0
}

main "$@"
exit $?
