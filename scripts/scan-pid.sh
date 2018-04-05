#!/bin/bash

if [ $(id -u) -ne 0 ]; then
        echo "This script must be run as root. Please try running this again as a sudo or root user." 1>&2
        exit 1
fi

if [[ $# != 2 ]] ; then
	echo "usage: plv scan-pid pid string"
	exit 1
fi

which gdb >& /dev/null
if [[ $? != 0 ]]; then
  echo "Error: Need to first install the 'gdb' package on this host (e.g., 'yum install gdb')"
  exit 1
fi

pid=${1}
string=${2}

mkdir -p "${pid}"
cd "${pid}"

# Get a copy of the process maps
cp /proc/${pid}/maps .

# Fix for loop using whole line
oIFS=${IFS}
IFS='
'

# Go through each range of memory and look for the string using gdb
for line in $(cat maps); do
	start=$(echo -n ${line} | sed -n 's/^\([0-9a-f]*\)-\([0-9a-f]*\) .*$/\1 \2/p' | cut -d" " -f1)
	stop=$(echo -n ${line} | sed -n 's/^\([0-9a-f]*\)-\([0-9a-f]*\) .*$/\1 \2/p' | cut -d" " -f2)
        perm=$(echo -n ${line} | cut -d" " -f2)

        if [[ ${perm} == "---p" ]]; then
                echo "[-PRIVATE-] ${line}"
        else
                filename="${pid}-${start}-${stop}.dump"
                gdb --quiet --batch-silent -pid ${pid} -ex "dump memory ${filename} 0x${start} 0x${stop}" 2>/dev/null

                if [ ! -e "$filename" ]; then
                        echo "[-MISSING-] ${line}"
                elif result=$(grep -e ${string} ${filename}); then
                        echo "[POLYVERSE] ${line}"
                else
                        echo "[-VANILLA-] ${line}"
                        rm ${filename}
                fi
        fi
done

cd ..
IFS=${oIFS}

