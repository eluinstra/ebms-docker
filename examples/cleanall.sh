#!/bin/sh

docker system prune --volumes
docker rmi -f $(docker images -a -q)
