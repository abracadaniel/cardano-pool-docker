#!/bin/bash

#
# This is an example on how to start 2 nodes on the mainnet. 1 block-producing and 1 relay.
#

# Stop and remove existing nodes
docker stop cardano-pioneer-relay
docker rm cardano-pioneer-relay

# Start relay node
docker run -it --rm \
    --network=host \
    -p 3001:3001 \
    -p 12789:12789 \
    -p 12799:12799 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3001" \
    -e NODE_NAME="relay" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="pioneer" \
    -e EKG_PORT="12789" \
    -e PROMETHEUS_PORT="12799" \
    -e RESOLVE_HOSTNAMES="True" \
    -e REPLACE_EXISTING_CONFIG="True" \
    -v $PWD/active_config/:/config/ \
    --entrypoint=bash \
    --name cardano-pioneer-relay \
    arrakis/cardano-node:pioneer2
