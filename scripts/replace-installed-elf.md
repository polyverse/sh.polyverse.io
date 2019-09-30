# replace-installed-elf
## Usage
```
Usage:

   curl https://sh.polyverse.com | [sudo] bash -s replace-installed-elf [<options>]

Options:

  --package <package>    Install <package> (default is all installed). --package can be specified multiple times.
  --help                 Display usage.
```
## Overview
The default recommended Polymorphic Linux installation is to run the install script (which adds repo.polyverse.io to the repository list) and then replace all the installed packages with a polymorphic version. For example:
```
$ apt-get update -y && apt-get upgrade -y
$ curl https://sh.polyverse.com | sh -s install czcw7pjshny8lzzog8bgiizfr demo@polyverse.io
$ apt-get -y update && apt-get -y install --reinstall $(dpkg --get-selections | awk '{print $1}')
```
This has worked well for fresh systems, but can potentially cause issues for systems that have been carefully configured. Specifically, the `apt-get -y install --reinstall $(dpkg --get-selections | awk '{print $1}')` command reinstalls packages in alphabetical order and some packages (e.g., nvidia drivers) may need to be installed after other packages.

Since Polymorphic Linux® is about unique ELF files, the immediate goal after the install script is to replace all existing off-the-shelf executables with a polymorphic version. This script is an alternative to our default installation that only replaces the ELF files (and skips configuration files, triggers, and all other non-ELF files).

The installation steps using this script is:
```
$ apt-get update -y && apt-get upgrade -y
$ curl https://sh.polyverse.com | sh -s install czcw7pjshny8lzzog8bgiizfr demo@polyverse.io
$ curl https://sh.polyverse.com | bash -s replace-installed-elf
```

## How it works
At a high-level, the script does the following:
 * Determine which packages are currently installed
 * Download the polymorphic version of those packages
 * Each package is extracted into a temporary folder and all non-ELF files are removed. The only exception is the `DEBIAN/control` file is also not removed, since this is required for the dpkg database to correctly know that the polymorphic version of the package was installed.
 * The ELF-only files are repackaged into a `.deb` package and then installed using `dpkg --install <deb_file>`.

A few important details:
  * All the package's metadata/control files in `/var/lib/dpkg/info` are temporary moved during installation and restored immediately afterwards. This prevents `dpkg --configure` from processing triggers during this script, but they are available for future package installations.
  * The md5sum of the installed ELF files are updated in the corresponding `.md5sums` file that exists in `/var/lib/dpkg/info`.
  * Since triggers are scripts, it's possible that a package can take an installed binary and then move it, or include the binary in a secondary build (e.g., `initramfs`), or anything else. Since we skip triggers, this can be addressed by running this script first, then subsequently performing `apt-get -y install --reinstall <package>`.
  
The source code can be reviewed here: https://github.com/polyverse/sh.polyverse.com/blob/master/scripts/replace-installed-elf

## Validation
Here are a few key expected outcomes after running this script:

 * If you didn't perform `apt-get upgrade` before running this script and there are, say, 7 packages that need to be upgraded, then this will be the same state afterwards.
 * There is a package you can install called `debsums` to check that all files on-disk match what was intended by the package. Running `debsums --all` after running the script will have no failures.
 * If this script replaced the ELF files from a polymorphic package, then the command `apt-cache policy <package>` will correctly indicate that the package was installed from `repo.polyverse.io`.
