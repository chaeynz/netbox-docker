ARG NETBOX_VER
FROM ghcr.io/netbox-community/netbox:${NETBOX_VER}

COPY ./plugin_requirements.txt /opt/netbox/
RUN /usr/local/bin/uv pip install -r /opt/netbox/plugin_requirements.txt

LABEL org.opencontainers.image.source="https://github.com/chaeynz/netbox-docker"
