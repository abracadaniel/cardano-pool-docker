#!/bin/bash

docker network create -d bridge cardano

docker run -it --rm \
    --network=cardano \
    --name mc4-relay1 \
    -p 3001:3001 \
    -p 12798:12798 \
    -e HOST_ADDR="0.0.0.0" \
    -e NODE_PORT="3001" \
    -e NODE_NAME="relay1" \
    -e NODE_TOPOLOGY="<IP-address of relay node>:3000/1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="mc4" \
    -e PROMETHEUS_PORT="12798" \
    -v $PWD/config/:/config/ \
    arradev/cardano-node:latest --start