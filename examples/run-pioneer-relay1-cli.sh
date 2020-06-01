#!/bin/bash

#
# This is an example on how to start 2 nodes on the mainnet. 1 block-producing and 1 relay.
#

# Start relay node
docker run -it --rm \
    --network=host \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3001" \
    -e NODE_NAME="relay1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="pioneer" \
    -e EKG_PORT="12789" \
    -e PROMETHEUS_PORT="12799" \
    -e RESOLVE_HOSTNAMES="True" \
    -e REPLACE_EXISTING_CONFIG="True" \
    -v $PWD/active_config/pioneer/relay1:/config/ \
    arrakis/cardano-node:pioneer2 --cli
