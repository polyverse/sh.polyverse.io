#!/bin/bash

# One complete pass is a BUILD
# BUILD has BLOCKS, which are the top-level objects in the JSON file
# BLOCKS has JOBS; each JOB is an expansion of the matrix
# JOBS has TESTS, which is an array of tests that are performed on the fully-expanded BUILD->BLOCK->JOB

# set PV_SH_ROOT so it can be used in JSON files to mount into containers, etc.
PV_TESTS_SH_FILENAME="${BASH_SOURCE[0]}"
export PV_SH_ROOT="$( cd "$( dirname "$PV_TESTS_SH_FILENAME" )" && cd .. && pwd )"

if [ -z "$PV_BASE_URL" ]; then
	export PV_BASE_URL="https://sh.polyverse.io"
fi

PV_FMT_BOLD=$(tput bold)
PV_FMT_NORMAL=$(tput sgr0)
PV_FMT_RED=$(tput setaf 1)
PV_FMT_GREEN=$(tput setaf 2)

main() {
	PV_NUM_PASS=0
	PV_NUM_FAIL=0

	parseCommandLine "$@"
	if [ $? -ne 0 ]; then
		return 1
	fi

	if [ -z "$PV_TEST_JSON_FILE" ]; then
		(>&2 echo "Error: missing required --json argument.")
		return 1
	fi

	if [ ! -f "$PV_TEST_JSON_FILE" ]; then
		(>&2 echo "Error: file '$PV_TEST_JSON_FILE' not found.")
		return 1
	fi

	BLOCK_INDEX=0
	while [ $BLOCK_INDEX -lt $(cat $PV_TEST_JSON_FILE | jq '.|length') ]; do
		_debugln "BLOCK_INDEX: $BLOCK_INDEX"
		BLOCK_JSON="$(cat $PV_TEST_JSON_FILE | jq '.['$BLOCK_INDEX']')"
		let BLOCK_INDEX=BLOCK_INDEX+1

		_debugln "BLOCK_INDEX: $BLOCK_INDEX"

		BLOCK_NAME="$(echo "$BLOCK_JSON" | jq -r '.name')"
		BLOCK_SOURCE="$(echo "$BLOCK_JSON" | jq -r '.source // empty')"

		if [ ! -z "$PV_BLOCK_FILTER" ] && [ "$BLOCK_NAME" != "$PV_BLOCK_FILTER" ]; then
			(>&2 echo "Skipping test block '$BLOCK_NAME'.")
			continue
		fi

		echo "Executing test block '$BLOCK_NAME'..."

		if [ ! -z "$BLOCK_SOURCE" ]; then
			BLOCK_SOURCE="$(eval "echo $BLOCK_SOURCE")"
			_echo "+ source $BLOCK_SOURCE"
			PV_DEFINE_INCLUDE="true"
			source $BLOCK_SOURCE
			PV_DEFINE_INCLUDE=""
		fi

		JOB_INDEX=0
		JOB_LENGTH=$(echo "$BLOCK_JSON" | jq '.matrix | length')

		while [ $JOB_INDEX -lt $JOB_LENGTH ]; do
			_debugln "JOB_INDEX: $JOB_INDEX"
			JOB_JSON="$(echo "$BLOCK_JSON" | jq '.matrix['$JOB_INDEX']')"
			let JOB_INDEX=JOB_INDEX+1

			ENV_INDEX=0
			while [ $ENV_INDEX -lt $(echo "$JOB_JSON" | jq '.env | length') ]; do
				_debugln "ENV_INDEX: $ENV_INDEX"
				PV_ENV="$(echo "$JOB_JSON" | jq -r '.env['$ENV_INDEX']')"
				let ENV_INDEX=ENV_INDEX+1

				_echo "+ export $PV_ENV"
				eval "export $PV_ENV"
			done

			_debugln "$(env | grep ^PV_)"

			BEFORE_TEST_INDEX=0
			BEFORE_TEST_LENGTH="$(echo "$BLOCK_JSON" | jq -r '.before_test | length')"
			while [ $BEFORE_TEST_INDEX -lt $BEFORE_TEST_LENGTH ]; do
				BEFORE_TEST_CMD="$(echo "$BLOCK_JSON" | jq -r '.before_test['$BEFORE_TEST_INDEX']')"
				echo "+ $BEFORE_TEST_CMD"
				eval "$BEFORE_TEST_CMD"
				let BEFORE_TEST_INDEX=BEFORE_TEST_INDEX+1
			done

			PV_CMD="$(echo "$BLOCK_JSON" | jq -r '.cmd // empty')"
			if [ ! -z "$PV_CMD" ]; then
				STDOUT=$(mktemp)
				eval "$PV_CMD" 2>/dev/null | tr -d '\r' > $STDOUT
				EXIT="${PIPESTATUS[0]}"

				(>&2 echo "+ $PV_CMD > \$STDOUT [\$EXIT: $EXIT]")

				_debugln "\$STDOUT"
				_debugln "$STDOUT"
			fi

			TESTS_INDEX=0
			TESTS_LENGTH=$(echo "$BLOCK_JSON" | jq '.tests | length')
			while [ $TESTS_INDEX -lt $TESTS_LENGTH ]; do
				_debugln "TESTS_INDEX: $TESTS_INDEX"

				PV_TEST="$(echo "$BLOCK_JSON" | jq -r '.tests['$TESTS_INDEX']')"

				let TESTS_INDEX=TESTS_INDEX+1

				_echo "++ test ${BLOCK_INDEX}.${JOB_INDEX}.${TESTS_INDEX}: $PV_TEST"
				RESULT="$(eval "if [[ $PV_TEST ]]; then echo pass; else echo fail; fi")"
				if [ "$RESULT" == "pass" ]; then
					RESULT="${PV_FMT_GREEN}$RESULT${PV_FMT_NORMAL}"
					let PV_NUM_PASS=PV_NUM_PASS+1
				else
					RESULT="${PV_FMT_RED}$RESULT${PV_FMT_NORMAL}"
					let PV_NUM_FAIL=PV_NUM_FAIL+1
				fi
				(>&2 echo -e "+++ [[ "$(eval "echo \"$PV_TEST\"")" ]] [$RESULT]")
			done

			AFTER_TEST_INDEX=0
			AFTER_TEST_LENGTH="$(echo "$BLOCK_JSON" | jq -r '.after_test | length')"
			while [ $AFTER_TEST_INDEX -lt $AFTER_TEST_LENGTH ]; do
				AFTER_TEST_CMD="$(echo "$BLOCK_JSON" | jq -r '.after_test['$AFTER_TEST_INDEX']')"
				echo "+ $AFTER_TEST_CMD"
				eval "$AFTER_TEST_CMD"
				if [ $? -ne 0 ]; then
					echo "Error: after_test command '$AFTER_TEST_CMD' returned non-zero."
					return 1
				fi
				let AFTER_TEST_INDEX=AFTER_TEST_INDEX+1
			done
		done
	done

	echo "pass: $PV_NUM_PASS, fail: $PV_NUM_FAIL"

	return $PV_NUM_FAIL
}

parseCommandLine() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--json)
				shift
				export PV_TEST_JSON_FILE="$1"
				;;
			--block)
				shift
				(>&2 echo "Setting PV_BLOCK_FILTER=\"$1\"")
				export PV_BLOCK_FILTER="$1"
				;;
			--debug)
				PV_DEBUG=true
				;;
			*)
				(>&2 echo "Error: unexpected argument '$1'.")
				return 1
		esac
		shift
	done

	return 0
}

_echo() {
	(>&2 echo -e "$1")
}

_debugln() {
	if [ ! -z "$PV_DEBUG" ]; then
		_echo "$1"
	fi
}

_eval() {
	(>&2 echo "+ $1")
	(>&2 eval "$1")
}

main "$@"
exit $?
