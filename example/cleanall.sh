#!/bin/sh

# docker image prune -a
# docker container prune
# docker volume prune
# docker network prune
docker system prune --volumes

docker rmi -f $(docker images -a -q)
