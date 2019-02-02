#!/bin/bash

LENGTH="$(cat t_info.json | jq '. | length')"
INDEX=0

NUM_PASS=0
NUM_FAIL=0

while [ $INDEX -lt $LENGTH ]; do
	IMAGE_NAME="$(cat t_info.json | jq -r '.['$INDEX'].image')"
	echo "IMAGE_NAME: $IMAGE_NAME"

	INFO="$(docker run --rm -v $PWD/../scripts:/opt/pv $IMAGE_NAME sh /opt/pv/info)"
	if [ ! -z "$PV_DEBUG" ]; then
		echo "$INFO"
	fi

	ASSERT_LENGTH="$(cat t_info.json | jq -r '.['$INDEX'].asserts | length')"
	ASSERT_INDEX=0
	while [ $ASSERT_INDEX -lt $ASSERT_LENGTH ]; do
		ASSERTION="$(cat t_info.json | jq -r '.['$INDEX'].asserts['$ASSERT_INDEX']')"
		printf "check: $ASSERTION"

		if [ ! -z "$(echo "$INFO" | grep "^$ASSERTION\$")" ]; then
			printf " [pass]\n"
			let NUM_PASS=NUM_PASS+1
		else
			printf " [fail]\n"
			let NUM_FAIL=NUM_FAIL+1
		fi

		let ASSERT_INDEX=ASSERT_INDEX+1
	done
	
	let INDEX=INDEX+1
done

let NUM_TOTAL=NUM_PASS+NUM_FAIL

echo "Results: $NUM_PASS of $NUM_TOTAL passed."
exit $NUM_FAIL

#DOCKER_IMAGES="centos:6 centos:7 debian alpine:3.6 alpine:3.7"
#for DOCKER_IMAGE in $DOCKER_IMAGES; do
#	docker run -it -v $PWD/../scripts:/opt/pv $DOCKER_IMAGE sh -c "cd /opt/pv; cat info | sh -s"
#done
