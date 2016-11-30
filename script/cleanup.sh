#!/bin/sh
echo cleanup started
echo stop all containers
docker stop $(docker ps -a -q)
echo removed untagged images
docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")
docker rm -v $(docker ps -a -q -f status=exited)
echo cleanup complete