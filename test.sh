#!/bin/bash

EXIT_CODE=0

cd tests
TESTS="$(ls -p *.sh)"
for TEST in $TESTS; do
	bash $TEST
	let EXIT_CODE=EXIT_CODE+$?
done

echo "Exiting with code '$EXIT_CODE'."
exit $EXIT_CODE
