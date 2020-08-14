#!/usr/bin/env bash
set -eou pipefail
cd `dirname "$0"`
source ./config.sh &> /dev/null || source ./config.sample.sh

md5=$(echo $PWD|md5)

if [ "$(basename "$0")" = "run-x86_64.sh" ]; then
	CONTAINER_NAME="${PWD##*/}-x86_64-$(echo $md5|cut -c 1-8)"
	DOCKER_IMAGE_NAME=$DOCKER_X86_64_TAG
else
	CONTAINER_NAME="${PWD##*/}-i686-$(echo $md5|cut -c 1-8)"
	DOCKER_IMAGE_NAME=$DOCKER_I686_TAG
fi

docker start "$CONTAINER_NAME" &> /dev/null || {
	echo "Creating new container..."
	docker run \
		--volume "$PWD":/base \
		--workdir /base \
		--detach \
		--name "$CONTAINER_NAME" \
		--tty \
		"$DOCKER_IMAGE_NAME"
}

docker exec --interactive --tty "$CONTAINER_NAME" \
	/data/data/com.termux/files/usr/bin/login
