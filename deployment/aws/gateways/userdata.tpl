#!/bin/bash

echo ${pem} | base64 -d > /tmp/cacert.pem 

# USERNAME for the api credentials to the controller.
USERNAME=${api_username}

# we need to provision the api credentials to be able to register the newly created
# gateway to the controller.
#
# in this example, we will use aws secret manager to retreive the password and use hardcoded value of username to $USERNAME.

# Install the latest AWS cli
sed -i -e 's/^#deb/deb/' /etc/apt/sources.list  # apt sources are now commented out by default
apt-get update
apt-get install --yes python3-pip
pip3 install --user --upgrade awscli

# get the aws secret with awscli
# TODO Create aws sts for temporary credentials so we can read the password from aws secret manager.
# cat >/tmp/password-executable-2 <<EOL
# #!/usr/bin/python3
# import json
# import shlex
# import subprocess
# out = subprocess.check_output(shlex.split("""aws --region ${aws_region} secretsmanager get-secret-value --secret-id ${aws_secret_arn}"""))
# secret_string = json.loads(out.decode())['SecretString']
# out = {"password": secret_string}
# print(json.dumps(out))
# EOL


# Example with hardcoded password. the expected format for password-executable.
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
    --username $USERNAME \
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
    --username $USERNAME \
    --password-path /tmp/password-executable
EOL
