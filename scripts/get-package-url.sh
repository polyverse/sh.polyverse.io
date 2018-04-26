#!/bin/sh
  
LOCS=""
LOCS="$LOCS http://vault.centos.org/6.0/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.0/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.1/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.1/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.2/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.2/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.3/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.3/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.4/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.4/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.5/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.5/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.6/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.6/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.7/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.7/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.8/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.8/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.9/os/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/6.9/updates/x86_64/Packages/"
LOCS="$LOCS http://vault.centos.org/7.0.1406/os/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.0.1406/updates/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.1.1503/os/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.1.1503/updates/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.2.1511/os/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.2.1511/updates/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.3.1611/os/x86_64/Packages"
LOCS="$LOCS http://vault.centos.org/7.3.1611/updates/x86_64/Packages"
LOCS="$LOCS http://mirror.centos.org/centos/7.4.1708/os/x86_64/Packages/"
LOCS="$LOCS http://mirror.centos.org/centos/7.4.1708/updates/x86_64/Packages/"
LOGS="$LOCS http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/23/Everything/x86_64/os/"
LOGS="$LOCS http://download.fedoraproject.org/pub/archive/fedora/linux/updates/23/x86_64/"
LOGS="$LOCS http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/24/Everything/x86_64/os/"
LOGS="$LOCS http://download.fedoraproject.org/pub/archive/fedora/linux/updates/24/x86_64/"
LOGS="$LOCS http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/25/Everything/x86_64/os/"
LOGS="$LOCS http://download.fedoraproject.org/pub/archive/fedora/linux/updates/25/x86_64/"

function GetPackageURL() {
        FILENAME="$1"

        for LOC in $LOCS; do
                (>&2 printf ".")
                if [ ! -z "$(curl -sI $LOC/$FILENAME | grep "200 OK")" ]; then
                        (>&2 printf "\n")
                        echo $LOC/$FILENAME
                        return 0
                fi
        done

        (>&2 printf "\n")
        return 1
}

RESULT="$(GetPackageURL $1)"
EXITCODE="$?"

if [ $EXITCODE -ne 0 ]; then
        (>&2 echo "Not found.")
        exit 1
fi

echo "$RESULT"
