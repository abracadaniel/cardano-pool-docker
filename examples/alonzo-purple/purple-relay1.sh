#!/bin/bash

docker stop purple-relay1
docker rm purple-relay1
docker run -it \
    --restart=unless-stopped \
    --network=host \
    --name purple-relay1 \
    -p 3000:3000 \
    -p 12798:12798 \
    -e HOST_ADDR="127.0.0.1" \
    -e NODE_PORT="3000" \
    -e NODE_NAME="relay1" \
    -e NODE_TOPOLOGY="127.0.0.1:3001/1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="alonzo-purple" \
    -e PROMETHEUS_PORT="12798" \
    -e AUTO_TOPOLOGY=False \
    -v $PWD/config/:/config/ \
    arradev/cardano-pool:1.0.2 --start
