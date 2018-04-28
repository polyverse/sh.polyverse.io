# sh.polyverse.io

These are a set of scripts designed to provide a suite of "no install" utilities for customers of Polymorphic Linux.

Usage: `curl https://sh.polyverse.io | sh -s <subcommand> [<options>]`

## Development

Subcommands can be added by adding an additional script to the `scripts/` folder. A few guidelines:

* scripts should be sh-compatible (meaning no bash). The first line should be `#!/bin/sh`.
* if you want to read command-line arguments, you must `shift` once beforehand. This is because the script is piped to `sh -s` which expects 

## Deployment

Deployments are done automatically using AWS CloudPipeline; they're triggered when commits are pushed to https://github.com/polyverse/sh.polyverse.io.


There are 2 pipelines, one that corresponds to the `master` branch and another for the `beta` branch. Developers can use the `beta` branch and should feel free to push early and often without worrying about breaking anything. Changes to the `master` branch must happen via GitHub PR.

