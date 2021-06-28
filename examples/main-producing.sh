#!/bin/bash

docker network create -d bridge cardano
docker run -it --rm \
    --network=cardano \
    --name main-producing \
    -p 3000:3000 \
    -p 12798:12798 \
    -e HOST_ADDR="0.0.0.0" \
    -e NODE_PORT="3000" \
    -e NODE_NAME="block-producing" \
    -e NODE_TOPOLOGY="<IP-address of relay1 node>:3000/1" \
    -e CARDANO_NETWORK="main" \
    -e PROMETHEUS_PORT="12798" \
    -v $PWD/config/:/config/ \
    arradev/cardano-pool:latest --start --staking