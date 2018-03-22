# plv

`plv` is a CLI front-end for Polymorphic Linux helper scripts.

The url https://git.io/plv is a shortened version of https://github.com/polyverse/plv/blob/master/main.sh, and all the scripts are available on our public GitHub repo https://github.com/polyverse/plv.

There are 2 ways to use this:

### No Install
You can run this without anything being installed on your system with the following command:
```
wget -qO- https://git.io/plv | sudo sh -s help
```
This example will display the tools help. You can replace "help" with any of the listed subcommands.

### Install
To make the command-line easier, you can download it to a folder that is part of your PATH:
```
sudo wget -O /usr/bin/plv https://git.io/plv
sudo chmod +x /usr/bin/plv
plv help
```
At this point, you can just run a subcommand with `plv <subcommand>`.
