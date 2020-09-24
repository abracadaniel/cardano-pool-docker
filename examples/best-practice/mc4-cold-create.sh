#!/bin/bash

docker network create -d bridge cardano

docker run -it --rm \
    --name mc4-cold-create \
    --network=cardano \
    -e CARDANO_NETWORK="mc4" \
    -e NODE_NAME="cold-create" \
    -e POOL_PLEDGE="100000000000" \
    -e POOL_COST="1000000000" \
    -e POOL_MARGIN="0.05" \
    -e METADATA_URL="<URL of metadata.json>" \
    -e PUBLIC_RELAY_IP="<Public IP-address of relay node>" \
    -e PUBLIC_RELAY_PORT="3000" \
    -v $PWD/config/:/config/ \
    arradev/cardano-node:latest --cold-create