#!/bin/sh

plv_apk() {
	echo "Alpine: NOT YET IMPLEMENTED."
}

plv_apt() {
	echo "Ubuntu: NOT YET IMPLEMENTED."
}

plv_yum() {
	echo "CentOS: NOT YET IMPLEMENTED."
}

case $PLV_DISTRO in
        alpine)
                PLV_FUNC="plv_apk"
                ;;
        centos | fedora)
                PLV_FUNC="plv_yum"
                ;;
        ubuntu)
                PLV_FUNC="plv_apt"
                ;;
        *)
                (>&2 echo "Error: unsupported distro [Distro: '$PLV_DISTRO', Release: '$PLV_RELEASE', Arch: '$PLV_ARCH']" )
                exit 1
                ;;
esac

eval "$PLV_FUNC"

echo "PLV_DISTRO: $PLV_DISTRO"
echo "PLV_RELEASE: $PLV_RELEASE"
echo "PLV_ARCH: $PLV_ARCH"
