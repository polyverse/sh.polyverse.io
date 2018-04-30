# sh.polyverse.io

These are a set of scripts designed to provide a suite of "no install" utilities for customers of Polymorphic Linux.

Usage: `curl https://sh.polyverse.io | sh -s <subcommand> [<options>]`

## Development

Subcommands can be added by adding an additional script to the `scripts/` folder. A few guidelines:

* Scripts should be sh-compatible (meaning no bash). The first line should be `#!/bin/sh`.
* If you want to read command-line arguments, you must `shift` once beforehand. This is because the subcommand is passed as $1 to prevent `sh -s` from processing subcommand options as `sh` options.
* Include `SHORT_DESCRIPTION="<some description>"` in the script somewhere for it to be published as part of the parent script's usage.

## Testing

There is a variable called `PV_BASE_URL` that can be set to change the behavior of where subcommand scripts will be pulled from.

To test locally, you can `cd` to the repo root folder and run the command as follows:
```
cat main.sh | PV_BASE_URL="file:///$PWD" sh -s <subcommand> [<options>]
```

To test on the beta site, run the command as follows:
```
curl https://sh-beta.polyverse.io | PV_BASE_URL="https://sh-beta.polyverse.io" sh -s <subcommand> [<options>]
```

## Deployment

Deployments are done automatically using AWS CloudPipeline; they're triggered when commits are pushed to https://github.com/polyverse/sh.polyverse.io.

There are 2 pipelines:

1. Developers should use the `beta` branch and push early and often without worrying about breaking production.
2. Developers should never publish directly to the `master` branch; all production deployments must be the result of a PR request.

AWS CloudPipeline pulls the commit and places them in an AWS S3 bucket which is then served directly via AWS CloudFront.
