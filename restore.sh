#!/bin/bash

docker run -it  --rm -v dokuwiki-storage:/var/dokuwiki-storage -v /opt/docker/dokuwiki_v2/backup:/backup ubuntu  tar xvpzf /backup/first.tgz -C /
