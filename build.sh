# renovate: datasource=github-tags depName=netbox-community/netbox versioning=loose
NETBOX_VER=v4.3.5

docker build --build-arg NETBOX_VER=${NETBOX_VER} -t ghcr.io/chaeynz/netbox:${NETBOX_VER} .
