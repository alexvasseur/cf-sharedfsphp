#!/bin/bash

SSHFS_CUPS=$(cat vcap_services.txt | jq 'to_entries|map(select(.key|contains("user-provided")))[0].value|map(select(.name|contains("sshfs")))[0].name' | grep -c "sshfs")

if [ "$SSHFS_CUPS" == "1" ]; then
    echo "Found SSHFS bound to app."

    # get credentials from the first bound sshfs service
    FS_HOST=$(cat vcap_services.txt | jq -r 'to_entries|map(select(.key|contains("user-provided")))[0].value|map(select(.name|contains("sshfs")))[0].credentials.host')
    echo $FS_HOST
else
    echo "ERROR - sshfs NOT FOUND!"
fi

