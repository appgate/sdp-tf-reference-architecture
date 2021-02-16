#!/bin/bash

echo ${pem} | base64 -d > /tmp/cacert.pem 

# TODO replace with aws secrets/vault
cat >/tmp/password-executable<<EOL
#!/bin/sh
echo '{"password": "admin"}'
EOL

chmod +x /tmp/password-executable


# Upscale!
/usr/share/admin-scripts/appgate-autoscale.py upscale \
    ${controller_dns} \
    --port 444 \
    --cacert /tmp/cacert.pem \
    --username admin \
    --site ${site_id} \
    --share-client-hostname  \
    --password-path /tmp/password-executable > /tmp/seed.json

mv /tmp/seed.json /home/cz/seed.json

# Setup downscale on shutdown
cat >/var/cache/cz-scripts/shutdown-script<<EOL
#!/bin/sh
/usr/share/admin-scripts/appgate-autoscale.py downscale \
    ${controller_dns} \
    --port 444 \
    --cacert /tmp/cacert.pem \
    --username admin \
    --password-path /tmp/password-executable
EOL
