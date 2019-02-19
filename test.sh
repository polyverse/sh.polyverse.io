#!/bin/bash

EXIT_CODE=0

./tests/test.sh --json tests/unit-tests.json
let EXIT_CODE=EXIT_CODE+$?

echo "Exiting with code '$EXIT_CODE'."
exit $EXIT_CODE
