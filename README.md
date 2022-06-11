# DEPRECATION NOTICE

Please note that this repository has been deprecated and is no longer actively maintained by Polyverse Corporation.  It may be removed in the future, but for now remains public for the benefit of any users.

Importantly, as the repository has not been maintained, it may contain unpatched security issues and other critical issues.  Use at your own risk.

While it is not maintained, we would graciously consider any pull requests in accordance with our Individual Contributor License Agreement.  https://github.com/polyverse/contributor-license-agreement

For any other issues, please feel free to contact info@polyverse.com

---

# sh.polyverse.io

These are a set of scripts designed to provide a suite of "no install" utilities for customers of Polymorphic Linux.

Usage: `curl https://sh.polyverse.io | sh -s <subcommand> [<options>]`

## Development

Subcommands can be added by adding an additional script to the `scripts/` folder. A few guidelines:

* Scripts should be sh-compatible (meaning no bash). The first line should be `#!/bin/sh`.
* Before processing command-line arguments, you must `shift` once beforehand. This is because the subcommand is passed as `$1` to prevent `sh -s` from processing subcommand options as `sh` options.
* Include `SHORT_DESCRIPTION="<some description>"` in the script somewhere for it to be published as part of the parent script's usage.
* Always support the `--help` option.

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

Before committing/pushing, run `./build.sh`. This re-generates the `./usage.txt` file.

There are 2 pipelines:

1. https://sh-beta.polyverse.io - Developers should use the `beta` branch and push early and often without worrying about breaking production.
2. https://sh.polyverse.io - Developers should never publish directly to the `master` branch; all production deployments must be the result of a PR request.

AWS CloudPipeline pulls the commit and places them in an AWS S3 bucket which is then served directly via AWS CloudFront.
