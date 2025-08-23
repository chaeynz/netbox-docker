# renovate: depName=ghcr.io/netbox-community/netbox datasource=docker
NETBOX_VER=4.3.5

docker build --build-arg NETBOX_VER=${NETBOX_VER} -t ghcr.io/chaeynz/netbox:${NETBOX_VER} .
