#!/bin/bash

PV_DEFINE_INCLUDE="true"
source ../scripts/install
PV_DEFINE_INCLUDE=""

RESULT="$(generatePFRACs "centos" "rpm" "6" "x86_64" "")"
if [ "$RESULT" == " centos_rpm_6_x86--64_os centos_rpm_6_x86--64_updates" ]; then
	echo "result: $RESULT [pass]"
else
	echo "result: $RESULT [fail]"
fi

RESULT="$(generatePFRACs "centos" "rpm" "6" "x86_64" "kernel")"
if [ "$RESULT" == " centos_rpm_6_x86--64_os centos_rpm_6_x86--64_updates centos_rpm_6_x86--64_os-kernel centos_rpm_6_x86--64_updates-kernel" ]; then
        echo "result: $RESULT [pass]"
else
        echo "result: $RESULT [fail]"
fi

RESULT="$(generatePFRACs "linuxmint" "rpm" "6" "x86_64" "")"
if [ $? -ne 0 ]; then
	echo "result: expecting non-zero exit code. [pass]"
else
	echo "result: expecting non-zero exit code. [fail]"
fi

RESULT="$(generatePFRACs "ubuntu" "deb" "xenial" "amd64" "")"
if [ "$RESULT" == " ubuntu_deb_xenial_binary--amd64_main ubuntu_deb_xenial-updates_binary--amd64_main ubuntu_deb_xenial-security_binary--amd64_main" ]; then
	echo "result: $RESULT [pass]"
else
	echo "result: $RESULT [fail]"
fi


