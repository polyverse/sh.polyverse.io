#!/bin/sh

usage() {
cat >&2 <<-EOF

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Usage:

  plv as-replace <node_role>

Node Roles: ESM611PV | ArcMC27PV | Logger65PV | SConnHostPV

Example:

  $ wget -qO- https://git.io/plv | sh -s as-replace ESM611PV

EOF
}

if [ $# -ne 1 ]; then
	usage
	exit 1
fi

if [ ! -d /opt.old ]; then
	echo "Please take a backup of the /opt folder called /opt.old."
	exit 1
fi

NODE_ROLE="$1"

case "$NODE_ROLE" in
	ESM611PV)
		STOP_CMD="/etc/init.d/arcsight_services stop"
		START_CMD="/etc/init.d/arcsight_services start"

		OVERLAYS="/opt/arcsight/logger/current/local/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/logger/current/local/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/manager/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/manager/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/logger/current/local/apache,httpd-2.4.6-67.el7.centos.2.x86_64.rpm"

		#OVERLAYS+=" /opt/arcsight/logger/current/local/mysql,mariadb-5.5.56-2.el7.x86_64.rpm"
		#OVERLAYS+=" /opt/arcsight/logger/current/local/mysql,mariadb-server-5.5.56-2.el7.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/logger/current/local/pgsql,postgresql-9.2.23-3.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/logger/current/local/pgsql,postgresql-server-9.2.23-3.el7_4.x86_64.rpm"
		;;
	ArcMC27PV)
		STOP_CMD="/etc/rc.d/init.d/arcsight_arcmc stop"
		START_CMD="/etc/rc.d/init.d/arcsight_arcmc start"

		OVERLAYS="/opt/arcsight/current/local/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/current/local/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/current/local/pgsql,postgresql-9.2.23-3.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/current/local/pgsql,postgresql-libs-9.2.23-3.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/current/local/pgsql,postgresql-server-9.2.23-3.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/current/local/apache,httpd-2.4.6-67.el7.centos.2.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/current/local/openssl,openssl-1.0.2k-8.el7.x86_64.rpm"
		OVERLAYS+=" /opt/arcsight/current/local/openssl/lib,openssl-libs-1.0.2k-8.el7.x86_64.rpm"

		OVERLAYS+=" /opt/arcsight/current/local/nss/lib,nss-3.28.4-8.el7.x86_64.rpm"
		;;
	Logger65PV)
		STOP_CMD="/etc/rc.d/init.d/arcsight_logger stop"
		START_CMD="/etc/rc.d/init.d/arcsight_logger start"
		
		OVERLAYS="/opt/current/arcsight/connector/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/current/arcsight/connector/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/current/local/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/current/local/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/current/local/mysql,mariadb-5.5.56-2.el7.x86_64.rpm"
		OVERLAYS+=" /opt/current/local/mysql,mariadb-server-5.5.56-2.el7.x86_64.rpm"

		OVERLAYS+=" /opt/current/local/pgsql,postgresql-9.2.23-3.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/current/local/pgsql,postgresql-libs-9.2.23-3.el7_4.x86_64.rpm"
		OVERLAYS+=" /opt/current/local/pgsql,postgresql-server-9.2.23-3.el7_4.x86_64.rpm"

		OVERLAYS+=" /opt/current/local/apache,httpd-2.4.6-67.el7.centos.2.x86_64.rpm"
		;;
	SConnHostPV)
		OVERLAY="/opt/smartconnectors/syslog/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAY+=" /opt/smartconnectors/syslog/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/smartconnectors/syslog/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/smartconnectors/LinuxAudit/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAY+=" /opt/smartconnectors/LinuxAudit/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/arcsight/connectors/windows/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAY+=" /opt/arcsight/connectors/windows/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/arcsight/connectors/netevents/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAY+=" /opt/arcsight/connectors/netevents/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/arcsight/connectors/netevents/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/arcsight/connectors/nix-events/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAY+=" /opt/arcsight/connectors/nix-events/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		OVERLAY+=" /opt/arcsight/connectors/syslog-gen/current/jre,java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64.rpm"
		OVERLAY+=" /opt/arcsight/connectors/syslog-gen/current/jre,java-1.8.0-openjdk-headless-1.8.0.161-0.b14.el7_4.x86_64.rpm"

		# /opt/smartconnectors/syslog/current/bin/nss
		# /opt/smartconnectors/LinuxAudit/current/bin/nss
		# /opt/arcsight/connectors/windows/current/bin/nss
		# /opt/arcsight/connectors/netevents/current/bin/nss
		# /opt/arcsight/connectors/nix-events/current/bin/nss
		# /opt/arcsight/connectors/syslog-gen/current/bin/nss
		;;
	*)
		echo "error: unknown role '$NODE_ROLE'."
		usage
		exit 1
esac

for OVERLAY in $OVERLAYS; do
	INSTALL_ROOT="${OVERLAY%,*}"
	PACKAGE_NAME="${OVERLAY#*,}"
	echo "PACKAGE_NAME: $PACKAGE_NAME, INSTALL_ROOT: $INSTALL_ROOT"
	wget -qO- https://git.io/plv | sh -s extract-rpm $PACKAGE_NAME --install-root $INSTALL_ROOT
done
