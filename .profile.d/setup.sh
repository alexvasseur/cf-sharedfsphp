#!/bin/bash
#
#  Setup wp-content on SSHFS
#   Author:  Daniel Mikusa <dmikusa@pivotal.io>
#     Date:  4/23/2015
#
set -eo pipefail

# Do not "exit 0" as this will also exit the container staging process

# move scripts out of public directory
echo ".profile.d/*.sh in action"
echo $HOME
ls -a $HOME

# if there's a .ssh folder uploaded, move it outside the public folder and fix permissions
if [ -d $HOME/.ssh ]; then
    chmod 600 $HOME/.ssh/*
    chmod 644 $HOME/.ssh/*.pub || true 
fi

# if there's a known_hosts file provided, enable StrictHostKeyChecking
if [ -f $HOME/.ssh/known_hosts ]; then
    chmod 644 $HOME/.ssh/known_hosts 
    SSHFS_OPTS="-o StrictHostKeyChecking=yes -o UserKnownHostsFile=$HOME/.ssh/known_hosts $SSHFS_OPTS"
else
    SSHFS_OPTS="-o StrictHostKeyChecking=no $SSHFS_OPTS"
fi

# If there's an SSHFS, mount it
echo "Checking for VCAP_SERVICES sshfs"
echo $VCAP_SERVICES

SSHFS_CUPS=$(echo $VCAP_SERVICES | jq 'to_entries|map(select(.key|contains("user-provided")))[0]|.value[0].name' | grep "sshfs" | wc -l)

if [ "$SSHFS_CUPS" == "1" ]; then
    echo "Found SSHFS bound to app."

    # get credentials from the first bound sshfs service
    FS_HOST=$(echo $VCAP_SERVICES | jq 'to_entries|map(select(.key|contains("user-provided")))[0]|.value[0].credentials.host')
    FS_USER=$(echo $VCAP_SERVICES | jq 'to_entries|map(select(.key|contains("user-provided")))[0]|.value[0].credentials.user')
    FS_PASS=$(echo $VCAP_SERVICES | jq 'to_entries|map(select(.key|contains("user-provided")))[0]|.value[0].credentials.password')
    FS_PORT=$(echo $VCAP_SERVICES | jq 'to_entries|map(select(.key|contains("user-provided")))[0]|.value[0].credentials.port')

    echo "Done parsing credentials"
    echo " host: $FS_HOST"

    # path to wp-content directory, this is where we mount the sshfs
    #WP_CONTENT="$HOME/htdocs/wp-content"

    # move WP defaults to /tmp to save a copy
    #mv "$WP_CONTENT" /tmp/wp-content

    # create a directory where we can mount sshfs
    mkdir -p "/home/vcap/sharedfs"
    #$WP_CONTENT"

    # use sshfs to mount the remote filesystem
#    echo "$FS_PASS" | \
#        sshfs "$FS_USER@$FS_HOST:" \
#            "/home/vcap/sharedfs" \
#            -o port=$FS_PORT \
#            -o uid=$(id -u vcap) \
#            -o gid=$(id -g vcap) \
#            -o password_stdin \
#            -o reconnect \
#            -o sshfs_debug $SSHFS_OPTS
    df -h # just for debugging purposes

    # copy WP original files to sshfs, -u makes it skip if remote is newer
    #rsync -rtvu /tmp/wp-content/ $(dirname "$WP_CONTENT")

    # remove WP original files
    #rm -rf /tmp/wp-content

    # write a warning file to sshfs, in case someone looks at the mount directly
    WF="/home/vcap/sharedfs/ WARNING_DO_NOT_EDIT_THIS_DIRECTORY"
    echo "!! WARNING !! DO NOT EDIT FILES IN THIS DIRECTORY!!\n" > "$WF"
    echo "These files are managed by a WordPress instance running " >> "$WF"
    echo "on CloudFoundry.  Editing them directly may break things " >> "$WF"
    echo " and changes may be overwritten the next time the " >> "$WF"
    echo "application is staged on CloudFoundry.\n" >> "$WF"
    echo "YOU HAVE BEEN WARNED!!" >> "$WF"

    # we're done
    echo "Done mounting SSHFS."
else
    echo "No SSHFS in VCAP_SERVICES"
fi
