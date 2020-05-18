#!/bin/bash

docker run -it --rm \
    --network=host \
    -p 3000:3000 \
    -p 3001:3001 \
    -p 12788:12788 \
    -p 12789:12789 \
    -p 12798:12798 \
    -p 12799:12799 \
    -e RELAY_IP='127.0.0.1' \
    -e PRODUCING_IP='127.0.0.1' \
    -v $PWD/active_config/:/config/ \
    --entrypoint=/bin/bash \
    arrakis/cardano-node:pioneer
