#!/bin/bash

docker network create -d bridge cardano

docker run -it --rm \
    --networkd=cardano \
    --name main-relay1 \
    -p 3000:3000 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="relay1" \
    -e NODE_TOPOLOGY="<IP-address of block-producing node>:3000/1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="main" \
    -e PROMETHEUS_PORT="12798" \
    -v $PWD/config/:/config/ \
    arrakis/cardano-node:latest --start