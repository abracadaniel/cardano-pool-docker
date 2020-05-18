#!/bin/bash

docker stop cardano-relay && docker stop cardano-producing
docker rm cardano-relay && docker rm cardano-producing

# Create network so the nodes can see eachother.
docker network create cardano

docker run -dit --rm \
    --network=cardano \
    -p 3000:3000 \
    -p 12788:12788 \
    -p 12798:12798 \
    -e RELAY_IP='cardano-relay' \
    -e PRODUCING_IP='cardano-producing' \
    -v $PWD/active_config/:/config/ \
    --name cardano-producing \
    arrakis/cardano-node:pioneer --resetproducing --resolve_docker_hostname --producing

docker run -dit --rm \
    --network=cardano \
    -p 3001:3001 \
    -p 12789:12789 \
    -p 12799:12799 \
    -e PRODUCING_IP='cardano-producing' \
    -e RELAY_IP='cardano-relay' \
    -v $PWD/active_config/:/config/ \
    --name cardano-relay \
    arrakis/cardano-node:pioneer --resetrelay --resolve_docker_hostname --relay

docker logs -f cardano-producing
