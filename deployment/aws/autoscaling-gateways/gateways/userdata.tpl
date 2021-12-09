#!/bin/bash

echo ${pem} | base64 -d > /tmp/cacert.pem

# USERNAME for the api credentials to the controller.
USERNAME=${api_username}

# we need to provision the api credentials to be able to register the newly created
# gateway to the controller.
#
# in this example, we will use aws secret manager to retrieve the password and use hardcoded value of username to $USERNAME.

# get the aws secret with awscli
# credentials for aws cli is provision by the ec2 assumed roles.
cat >/tmp/password-executable<<EOL
#!/usr/bin/python3
import json
import shlex
import subprocess
from time import sleep

MAX_TRIES = 6

shell_script = "aws --region ${aws_region} secretsmanager get-secret-value --secret-id ${aws_secret_arn}"
for i in range(MAX_TRIES):
    proc = subprocess.Popen(shell_script, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = proc.communicate()
    if stderr:
        print(stderr)
        sleep(10)
    else:
        secret_string = json.loads(stdout.decode())['SecretString']
        out = {"password": secret_string}
        print(json.dumps(out))
        break
EOL


# Example with hardcoded password. the expected format for password-executable.
# the password is the same as 'appgate_local_user.gateway_api_user.password'
# cat >/tmp/password-executable<<EOL
# #!/bin/sh
# echo '{"password": "aws_appgate"}'
# EOL



chmod +x /tmp/password-executable


# appgate.autoscale.py register the new gateway to the collective.
/usr/share/admin-scripts/appgate-autoscale.py upscale \
    ${controller_dns} \
    --port 8443 \
    --cacert /tmp/cacert.pem \
    --username $USERNAME \
    --site ${site_id} \
    --share-client-hostname  \
    --password-path /tmp/password-executable > /tmp/seed.json

mv /tmp/seed.json /home/cz/seed.json

# shutdown-script is a shutdown hook for the appgate collective that will gracefully remove the gateway from the collective.
cat >/var/cache/cz-scripts/shutdown-script<<EOL
#!/bin/sh
/usr/share/admin-scripts/appgate-autoscale.py downscale \
    ${controller_dns} \
    --port 8443 \
    --cacert /tmp/cacert.pem \
    --username $USERNAME \
    --password-path /tmp/password-executable
EOL
