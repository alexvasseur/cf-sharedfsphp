# cf-sharedfsphp

## Overview

A simple PHP app that shows:
- SSHFS as a simple shared content folder between apps / instances of apps
- Using Cloud Foundry .profile.d/*.sh staging hook to setup SSHFS thru shell script
- Using a User Provided service "sshfs" declaration to avoid hardcoding SSHFS endpoint in the app

The use case targets application that do need some basic shared storage and have to be deployed into container environment such as Cloud Foundry.

Your best choice would be to use a Cloud Native storage API such as S3 using Amazon on public cloud, EMC ECS and the Pivotal Cloud Foundry service broker to have S3 as a service on premise, etc.

You can check a Java app doing the same with equivalent techniques at [https://github.com/avasseur-pivotal/cf-sharedfs]

## Quickstart

You can review manifest.yml and use the deploy.sh script which creates a user provided service
```
cf create-user-provided-service sshfs -p '{"host":"192.168.1.5", "username":"ubuntu", "password":"password", "port":"22"}'
# this also support "path":"/home/vcap/sharedfs" (default)

cf push

cf ssh cfsharedfs
  ls /home/vcap/sharedfs

cf scale -i 2
```
The ``cf logs --recent cfsharedfs`` will show you what happened and show the result of ``df -h`` as which will show the SSHFS filesystem

## Key design points

The SSHFS script is in .profile.d/setup_sshfs.sh . The Cloud Foundry stager does execute all *.sh in ./profile.d/ - this is a feature usually leveraged in buildpacks but that your app can also leverage this.

The shell script is parsing ``VCAP_SERVICE`` JSON using ``jq`` which is also included by default in the Cloud Foundry container.
Read the script for more information - [https://github.com/avasseur-pivotal/cf-sharedfsphp/blob/master/.profile.d/setup_sshfs.sh]


## Pros / Cons of SSHFS

Cloud Foundry container does have sshfs and FUSE in it.
Pivotal has a SSHFS server side implementation for you to try that is multitenant and with a Cloud Foundry service broker but you can run this app with any VM exposing files over ssh (as any Linux with ssh would do)
Cloud Foundry teams are working on a disk-as-a-service for container with pluggable block storage backend as well.
(contact me for more details)

Once all this is ready, FUSE & sshfs in container might become irrelevant as it is a less scalable approach to the same problem space.
This said, sshfs works in minutes. This apps shows a Java init, but another project shows also a shell based init using Cloud Foundry .profile.d/ stager hook

 

