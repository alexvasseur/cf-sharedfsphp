#!/bin/bash

# A Cloud Foundry deployment with user provided service

cf create-user-provided-service sshfs -p '{"host":"192.168.1.19", "username":"ubuntu", "password":"password", "port":"22"}'
# also support "path":"/home/vcap/sharedfs" (default)

cf push 

cf logs cfsharedfsphp --recent


