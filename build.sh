#!/bin/bash

#set -x 

VERSION="$1"
if [[ -z $1 ]]; then echo "ERROR: not exist 1 arg"; exit 1; fi
COMPONENT="dokuwiki_v2"
FROM="local/home"
TO="local/home"

#docker login docker.cloud.mvd.ru -u hello -p world

docker build -t ${TO}/${COMPONENT}:${VERSION} .
#docker tag      ${FROM}/${COMPONENT}:${VERSION} ${TO}/${COMPONENT}:latest
#docker push     ${TO}/${COMPONENT}:${VERSION}
#docker push     ${TO}/${COMPONENT}:latest
