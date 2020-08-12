#!/bin/bash

docker network create -d bridge cardano

docker run -it --rm \
    --name mc4-block-producing \
    --network=cardano \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e CARDANO_NETWORK="mc4" \
    -e NODE_PORT="3000" \
    -e NODE_NAME="block-producing" \
    -e NODE_TOPOLOGY="<IP-address of relay node>:3001/1" \
    -v $PWD/config/:/config/ \
    arrakis/cardano-node:latest --cold-register --start --staking