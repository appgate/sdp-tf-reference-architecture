#!/bin/bash

# seed the first controller, and enable admin interface on :8443
cz-seed \
    --password cz cz \
    --dhcp-ipv4 eth0 \
    --enable-logserver \
    --no-registration \
    --hostname "${HOSTNAME}" \
    | jq '.remote.adminInterface.hostname = .remote.peerInterface.hostname | .remote.adminInterface.allowSources = .remote.peerInterface.allowSources' >> /home/cz/seed.json
