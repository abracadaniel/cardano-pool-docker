#!/bin/bash

docker network create -d bridge cardano

docker run -it --rm \
    --name main-registration \
    --network=cardano \
    -p 3000:3000 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="registration" \
    -e NODE_TOPOLOGY="<IP-address of relay1 node>:3000/1" \
    -e CARDANO_NETWORK="main" \
    -e CREATE_STAKEPOOL="True" \
    -e POOL_PLEDGE="100000000000" \
    -e POOL_COST="1000000000" \
    -e POOL_MARGIN="0.05" \
    -e METADATA_URL="<URL of metadata.json>" \
    -v $PWD/config/:/config/ \
    arrakis/cardano-node:latest --start --staking