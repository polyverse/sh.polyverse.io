#!/bin/sh

PV_DEFINE_INCLUDE="true"
. "$1"
PV_DEFINE_INCLUDE=""

shift

eval "$@"
exit $?
