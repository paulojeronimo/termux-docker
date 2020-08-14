#!/usr/bin/env bash
set -eou pipefail
DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL:-'https://index.docker.io/v1/'}

cd `dirname "$0"`
source ./config.sh &> /dev/null || source ./config.sample.sh
which jq &> /dev/null || { echo "Install jq!"; exit 1; }

# Ref: https://stackoverflow.com/a/54423358/8410767
is_logged_in() {
  jq -e --arg url $DOCKER_REGISTRY_URL '.auths | has($url)' ~/.docker/config.json > /dev/null;
}

# Code to solve issues/1.txt temporarily
wget -c http://dl.bintray.com/termux/bootstrap/bootstrap-i686-v25.zip -O i686/bootstrap-i686-v25.zip
wget -c http://dl.bintray.com/termux/bootstrap/bootstrap-x86_64-v25.zip -O x86_64/bootstrap-x86_64-v25.zip

docker build -t $DOCKER_I686_TAG -f i686/Dockerfile .
docker build -t $DOCKER_X86_64_TAG -f x86_64/Dockerfile .

if is_logged_in && [ "${1:-}" = "--push" ]; then
	docker push $DOCKER_I686_TAG
	docker push $DOCKER_X86_64_TAG
fi
