#!/bin/bash

docker stop purple-registration
docker rm purple-registration:
docker run -it --rm \
    --name purple-registration \
    --network=host \
    -e HOST_ADDR="127.0.0.1" \
    -e NODE_PORT="3001" \
    -e NODE_NAME="registration" \
    -e NODE_TOPOLOGY="127.0.0.1:3000/1" \
    -e CARDANO_NETWORK="alonzo-purple" \
    -e POOL_PLEDGE="100000000000" \
    -e POOL_COST="340000000" \
    -e POOL_MARGIN="0.05" \
    -e METADATA_URL="https://arrapool.io/meta/arra.json" \
    -e PROMETHEUS_PORT="12799" \
    -v $PWD/config/:/config/ \
    arradev/cardano-pool:1.0.2 --create --start --staking
