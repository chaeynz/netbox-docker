ARG NETBOX_VER=4.3.6

FROM ghcr.io/netbox-community/netbox:v${NETBOX_VER}

COPY ./plugin_requirements.txt /opt/netbox/
RUN /usr/local/bin/uv pip install -r /opt/netbox/plugin_requirements.txt
