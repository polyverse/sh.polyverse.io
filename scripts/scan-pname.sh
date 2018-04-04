#!/bin/bash

if [ $(id -u) -ne 0 ]; then
        echo "This script must be run as root. Please try running this again as a sudo or root user." 1>&2
        exit 1
fi

if [[ $# != 2 ]] ; then
	echo "usage: plv scan-pname pname string"
	exit 1
fi

pname=${1}
string=${2}

which lsof >& /dev/null
if [[ $? != 0 ]]; then
  echo "ERROR: Need to first install the 'lsof' package on this host (e.g., 'yum install lsof')"
  exit 1
fi
which pgrep >& /dev/null
if [[ $? != 0 ]]; then
  echo "ERROR: Need to first install the 'pgrep' package on this host (e.g., 'yum install procps-ng')"
  exit 1
fi

for pid in $(pgrep $pname); do
  echo "PID ${pid}:"
  liblist=$(lsof -p $pid | grep '\.so' | awk '{print $9}')
  for lib in $liblist ; do
    numFound=$(strings $liblist | grep -i -- $string | wc -l)
    echo "$numFound     $lib"
  done
done

