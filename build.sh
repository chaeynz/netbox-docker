#!/bin/bash

# renovate: datasource=github-tags depName=netbox-community/netbox versioning=loose
NETBOX_VER=v4.3.6

IMAGE_NAME=ghcr.io/chaeynz/netbox

TAG=$(curl --silent https://api.github.com/repos/chaeynz/netbox-docker/tags | jq -r '.[0].name')

NETBOX_VER_FROM_TAG="${TAG%%-*}"
REPO_VER_FROM_TAG="${TAG#*-}"

if [ "${NETBOX_VER}" != "${NETBOX_VER_FROM_TAG}" ]; then
    echo "NETBOX_VER doesn't match the NETBOX_VER_FROM_TAG" >&2
    exit 1
else
    echo "NETBOX_VER matches NETBOX_VER_FROM_TAG"
fi
DOCKER_TAGS=(
    "$TAG"
    latest
)
DOCKERFILE="./Dockerfile"
DOCKER_BUILD_ARGS=(
    -f "$DOCKERFILE"
)

for tag in "${DOCKER_TAGS[@]}"; do
    DOCKER_BUILD_ARGS+=(-t "$IMAGE_NAME":"$tag")
done

echo ${DOCKER_BUILD_ARGS[@]}

if [ "${2}" == "--push" ]; then
  DOCKER_BUILD_ARGS+=(
    --output=type=image
    --push
  )
else
  DOCKER_BUILD_ARGS+=(
    --output=type=docker
  )
fi

docker build --build-arg NETBOX_VER=${NETBOX_VER} "${DOCKER_BUILD_ARGS[@]}" .
