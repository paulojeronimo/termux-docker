#!/usr/bin/env bash
set -eou pipefail
BASE_DIR=`cd "$(dirname "$0")"; pwd -P`
cd "$BASE_DIR"

config=./config.sh
source $config &> /dev/null || {
  config=./config.sample.sh
  source $config
}
echo "Configuration read from $PWD/${config#./}"

case "$OSTYPE" in
  darwin*)
    md5sum=$(which md5);;
  linux-gnu)
    # TODO: Fix this for other Linux flavors ...
    md5sum=$(which md5sum);;
  *)
    echo "$0 not supported for $OSTYPE!"
    exit 1
esac
md5=$(echo $PWD|$md5sum)

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
