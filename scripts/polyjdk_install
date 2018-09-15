#!/bin/sh

# defaults / initialization
TARBALL_FOLDER="/opt/arcsight"
NODEID="$HOSTNAME"
AUTHKEY=""
DOWNLOADONLY=""
UNINSTALL=""

#******************************************************************************#
#                                 functions                                    #
#******************************************************************************#

usage() {
cat >&2 <<-EOF
Installs Polymorphic OpenJDK for ArcSight.

This script installs/uninstalls a Polymorphic OpenJDK on top of an existing
ArcSight installation using a side-car/overlay technique. In a nutshell, the
vendorized jre/ folder is renamed to jre.old/, a copy is made to jre.pv/, a
tarball containing a Polymorphic-version of OpenJDK is extracted over the
jre.pv/ folder, and then a jre/ symlink is created that points to jre.pv/.

The specific version of OpenJDK is checked for each instance of a vendorized
jre/ folder and the corresponding tarball is determined and downloaded.

Usage:

   ./polyjdk_install.sh <options>

Options:

   --authkey <authkey>               Polymorphic OpenJDK authorization key.
   --destination </path/to/folder>   Tarball download folder.
   --nodeid <nodeid>                 Identifier for this node. Default: \$HOSTAME
   --download-only                   Download the tarball, but don't install.
   --uninstall                       Uninstall Polymorphic OpenODK for ArcSight.
   --help                            Display usage.

Examples:

   - Default installation process
       $ ./polyjdk_install.sh --authkey <authkey>

   - Just download the tarball, but don't install. This is useful if you the
     installation will be on a separate host that doesn't have internet access.
       $ ./polyjdk_install.sh --authkey <authkey> --download-only

   - Install a pre-downloaded tarball. In this example, the tarball has been
     placed in /opt/arcsight.
       $ ./polyjdk_install.sh --destination /opt/arcsight

   - Uninstall
       $ ./polyjdk_install.sh --uninstall

EOF
}

# evals $1 and, if true, echos $2 to stderr and exits
function exitif() {
        eval "if [[ "$1" ]]; then (>&2 echo "$2"); exit 1; fi"
}

# echos out a command and then executes it
function echoeval() {
	# change text color to blue
	(>&2 printf '\033[0;34m')

	(>&2 echo "+ $1")
	eval "$1"
	_EXIT_CODE=$?

	# change text color back to "no color"
	(>&2 printf '\033[0m')

	return $_EXIT_CODE
}

# download $1 (filename) to $2 (destination folder)
function downloadScrambledTarball() {
        _FILENAME="$1"
        _DESTINATION="$2"

	exitif "-z \"$AUTHKEY\"" "Error: --authkey argument required."

	_CMD="wget --no-verbose --server-response -O $_DESTINATION/$_FILENAME \"https://repo.polyverse.io/files/scrambled?filename=$_FILENAME&nodeID=$NODEID&authKey=$AUTHKEY\""
        (>&2 echo "+ $_CMD")
        _RESULT="$(eval "$_CMD" 2>&1)"
        _EXIT_CODE=$?

        if [ $_EXIT_CODE -ne 0 ]; then
                (>&2 echo "Error: wget returned exit code '$_EXIT_CODE' with result '$_RESULT'.")
                return 1
        fi

        _HTTP_STATUS_CODE="$(echo "$_RESULT" | awk '/^  HTTP/{print $2}' | tail -1)"
        if [ -z "$_HTTP_STATUS_CODE" ]; then
                (>&2 echo "Error: unable to determine HTTP status code.")
                return 1
        fi

        if [ $_HTTP_STATUS_CODE -ne 200 ]; then
                (>&2 echo "Error: wget returned http status code '$HTTP_STATUS_CODE' with result '$_RESULT'.")
                return 1
        fi

        return 0
}

# looks in $1 (folder) for bin/java, parses result of "bin/java -version", and then maps that to a tarball filename
function getJdkFilename() {
        _FOLDER="$1"

	# make sure bin/java exists
	if [ ! -s "$_FOLDER/bin/java" ]; then
		echo "Error: cannot find file '$_FOLDER/bin/java'."
		return 1
	fi

	# grab the output of -version and parse the results into just the version (e.g., "1.8.0_111-b14")
        _JAVA_VERSION="$($_FOLDER/bin/java -version 2>&1 | grep Environment | sed 's/.*(build \(.*\))/\1/')"
        (>&2 echo "JAVA_VERSION: $_JAVA_VERSION" )

	# TO DO: if we change the filename convention to reflect JAVA_VERSION, then we can get rid of this mapping.
	case "$_JAVA_VERSION" in
		"1.7.0_75-b13")
			_JDK_FILENAME="arcsight-jdk-jdk7u75-b13.tar.gz"
			;;
		"1.7.0_97-b00")
			_JDK_FILENAME="arcsight-jdk-jdk7u97-b00.tar.gz"
			;;
		"1.7.0_101-b00")
			_JDK_FILENAME="arcsight-jdk-jdk7u101-b00.tar.gz"
			;;
		"1.7.0_121-b00")
			_JDK_FILENAME="arcsight-jdk-jdk7u121-b00.tar.gz"
			;;
		"1.7.0_121-b15")
			_JDK_FILENAME="arcsight-jdk-jdk7u121-b15.tar.gz"
			;;
		"1.7.0_141-b11")
			_JDK_FILENAME="arcsight-jdk-jdk7u141-b11.tar.gz"
			;;
		"1.8.0_111-b14")
			_JDK_FILENAME="arcsight-jdk-jdk8u111-b14.tar.gz"
			;;
		"1.8.0_121-b13")
			_JDK_FILENAME="arcsight-jdk-jdk8u121-b13.tar.gz"
			;;
		"1.8.0_131-b11")
			_JDK_FILENAME="arcsight-jdk-jdk8u131-b11.tar.gz"
			;;
		"1.8.0_141-b15")
			_JDK_FILENAME="arcsight-jdk-jdk8u141-b15.tar.gz"
			;;
		"1.8.0_151-b12")
			_JDK_FILENAME="arcsight-jdk-jdk8u151-b12.tar.gz"
			;;
		"1.8.0_161-b12")
			_JDK_FILENAME="arcsight-jdk-jdk8u161-b12.tar.gz"
			;;
		"1.8.0_181-b13")
			_JDK_FILENAME="arcsight-jdk-jdk8u181-b13.tar.gz"
			;;
		*)
			(>&2 echo "Error: unhandled java version '$_JAVA_VERSION'." )
			return 1
	esac

	(>&2 echo "JDK_FILENAME: $_JDK_FILENAME" )

	echo "$_JDK_FILENAME"
	return 0
}

function install() {
	_TARBALL_LOCATION="$1"
        _FOLDER="$2"
        _PARENT_FOLDER="${_FOLDER%/*}"

        echoeval "cd $_PARENT_FOLDER"

	_FOLDER_TYPE="$(stat --format=%F $_FOLDER)"
	case "$_FOLDER_TYPE" in
		"symbolic link")
			if [ ! -d "${_FOLDER}.pv" ]; then
				echo "Warning: destination '$_FOLDER' is a symlink, but folder '${_FOLDER}.pv' doesn't exist. This is unexpected."
				return 1
			fi
			echo "=> Found folder '${_FOLDER}.pv'. Looks like a re-install."
			;;
		"directory")
			if [ -d "${_FOLDER}.old" ] || [ -d "${_FOLDER}.pv" ]; then
				echo "Warning: destination '$_FOLDER' is not a symlink, but folder '${_FOLDER}.old' or '${_FOLDER}.pv' already exists. This is unexpected."
				return 1
			fi

			echo "=> Creating symlink/overlay structure to make rollback simple..."
			echoeval "su arcsight -c \"mv $_FOLDER ${_FOLDER}.old\""
			if [ $? -ne 0 ]; then
				echo "Warning: encountered issue renaming '$_FOLDER' to '${_FOLDER}.old'."
				return 1
			fi

			echoeval "su arcsight -c \"cp -a ${_FOLDER}.old ${_FOLDER}.pv\""
			if [ $? -ne 0 ]; then
				echo "Warning: encountered issue copying '${_FOLDER}.old' to '${_FOLDER}.pv'."
				return 1 
			fi

			echoeval "su arcsight -c \"ln -s ${_FOLDER}.pv $_FOLDER\""
			if [ $? -ne 0 ]; then
				echo "Warning: encountered creating symlink '$_FOLDER' to '${_FOLDER}.pv'."
				return 1
			fi
			;;
		*)
			echo "Error: unexpected folder type '$_FOLDER_TYPE'."
			return 1
	esac

	echoeval "cd ${_FOLDER}.pv"
	_EXECUTABLE_FILES="$(echoeval "tar -tzv -f $_TARBALL_LOCATION | grep -v ^[d,l] | grep '^...x' | awk '{print \$6}' | grep '\./jre/' | xargs")"
	echoeval "su arcsight -c \"tar --strip-components=2 -xvz -f $_TARBALL_LOCATION $_EXECUTABLE_FILES\" >/dev/null"
	if [ $? -ne 0 ]; then
		echo "Warning: encountered issue extracting tarball '$_TARBALL_LOCATION'. Rolling-back this portion."
		echoeval "rm -f $_FOLDER"
		echoeval "mv $_PARENT_FOLDER/jre.old $_FOLDER"
		echoeval "rm -frd $_PARENT_FOLDER/jre.pv"
		return 1
	fi

	return 0
}

function uninstall() {
	_FOLDER="$1"
	_PARENT_FOLDER="${_FOLDER%/*}"

	echoeval "cd $_PARENT_FOLDER"

	_FOLDER_TYPE="$(stat --format=%F $_FOLDER)"
	case "$_FOLDER_TYPE" in
		"symbolic link")
			if [ ! -d $_PARENT_FOLDER/jre.old ] || [ ! -d $_PARENT_FOLDER/jre.pv ]; then
				echo "Error: missing $_PARENT_FOLDER/jre.old or $_PARENT_FOLDER/jre.pv. Since this is unexpected, not making any changes."
				return 1
			fi

			echoeval "rm -f $_FOLDER"
			echoeval "mv $_PARENT_FOLDER/jre.old $_FOLDER"
			echoeval "rm -frd $_PARENT_FOLDER/jre.pv"
			;;
		"directory")
			echo "Error: expected folder '$_FOLDER' to be a symlink, but it's a directory. Doesn't look like Polymorphic OpenJDK was installed using this script."
			return 1
			;;
		*)
                        echo "Error: unexpected folder type '$_FOLDER_TYPE'."
                        return 1
	esac

	return 0
}

function serviceStartOrStop() {
	_OPERATION="$1"

	# list of all the service scripts that support start/stop operations
	_SERVICE_COMMANDS="/etc/rc.d/init.d/arcsight_arcmc /etc/rc.d/init.d/arcsight_services /etc/rc.d/init.d/arcsight_logger"

	for _SERVICE_COMMAND in $_SERVICE_COMMANDS; do
		if [ -s $_SERVICE_COMMAND ]; then
			echoeval "$_SERVICE_COMMAND $_OPERATION"
			return $?
		fi
	done

	(>&2 echo "No service command found. Not performing '$_OPERATION' operation.")
	return 0
}

function scanProcess() {
	for _PID in $(ps -axl --cols 1000 | grep java | awk '{print $3}'); do
		_LIBRARIES=$(lsof -p $_PID 2>&1 | grep '/opt/arcsight' | grep 'jre' | grep '\.so' |  sed -e 's/^.* \//\//'  -e 's/;.*$//')
		for _LIBRARY in $_LIBRARIES; do
			_NUM_FOUND=$(strings $_LIBRARY | grep -i -- "-PV-" | wc -l)
			if [ $_NUM_FOUND -ne 0 ]; then
				echo "true  $_LIBRARY"
			else
				echo "false $_LIBRARY"
			fi
		done
	done
}

#******************************************************************************#
#                                    main                                      #
#******************************************************************************#

# due to the way sh.polyverse.io works, $1 is used to determine which script to run
# but for the script itself, we want to get rid of the first argument
shift

if [ $# -eq 0 ]; then
        usage
        exit 1
fi

# enumerate all the command-line arguments and set variables accordingly
while (( $# )) ; do
        case $1 in
                --authkey)
                        shift
                        AUTHKEY="$1"
                        ;;
                --destination)
                        shift
                        TARBALL_FOLDER="$1"
                        ;;
                --nodeid)
                        shift
                        NODEID="$1"
                        ;;
                --download-only)
                        DOWNLOADONLY="true"
                        ;;
		--uninstall)
			UNINSTALL="true"
			;;
                --help)
                        usage
                        exit 1
                        ;;
                *)
                        echo "ERROR: Unhandled argument '$1'."
                        exit 1
        esac
        shift
done

# check pre-requisites
exitif "$(id -u) -ne 0" "This script must be run as root. Please try running this again as a sudo or root user."

which wget >& /dev/null
exitif "$? -ne 0" "Error: This script requires wget. Please install it and try running this again."

which lsof >& /dev/null
exitif "$? -ne 0" "Error: This script requires lsof. Please install it and try running this again."

# if --download-only is specified, just download the tarball and exit
if [ ! -z "$DOWNLOADONLY" ]; then
        mkdir -p $TARBALL_FOLDER >/dev/null 2>&1
        downloadScrambledTarball "$FILENAME" "$TARBALL_FOLDER"
        exit $?
fi

# determine if any arcsight-vendorized java processes are running. if so, stop the arcsight services.
echo "Determining status of Java-based ArcSight services..."
if [ -z "$(scanProcess)" ]; then
	echo "=> services not running."
else
	echo "=> services running."
	echo "Stopping services..."
	serviceStartOrStop stop
	exitif "$? -ne 0" "Error: issue occurred while attempting to stop the service."
fi

echo "Identifying ArcSight installations..."
FOLDERS="$(find /opt/arcsight | grep jre$ | grep -v Uninstall)"

for FOLDER in $FOLDERS; do
	echo "Found '$FOLDER'. Processing..."

	if [ "$UNINSTALL" == "true" ]; then
		echo "=> uninstalling..."
		uninstall "$FOLDER"
	else
		# each vendorized folder might potentially have a different jdk
		FILENAME="$(getJdkFilename "$FOLDER")"
		if [ $? -ne 0 ]; then
			echo "Warning: unsupported version of JDK found in '$FOLDER'. Skipping..."
		else
			# don't download the tarball if we already did it before.
			if [ ! -s "$TARBALL_FOLDER/$FILENAME" ]; then
				echo "=> Downloading '$FILENAME' to '$TARBALL_FOLDER'... This may take a few minutes."
				downloadScrambledTarball "$FILENAME" "$TARBALL_FOLDER"
				if [ $? -ne 0 ]; then
					echo "Warning: unable to download scrambled tarball '$FILENAME'."
				fi
			else
				echo "=> Found '$TARBALL_FOLDER/$FILENAME'. No need to download."
			fi

			if [ -s "$TARBALL_FOLDER/$FILENAME" ]; then
				echo "=> Installing '$TARBALL_FOLDER/$FILENAME' to '$FOLDER'..."
				install "$TARBALL_FOLDER/$FILENAME" "$FOLDER"
				if [ $? -ne 0 ]; then
					echo "Error: issue detected during installation to '$FOLDER'. Skipping..."
				fi
			else
				echo "Warning: file '$TARBALL_FOLDER/$FILENAME' is missing or empty. Skipping..."
			fi
		fi
	fi
done

echo "Starting services..."
serviceStartOrStop start

echo "Scanning processes... ('true' means you're protected)"
scanProcess

echo "Finished."
