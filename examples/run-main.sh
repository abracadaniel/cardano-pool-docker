#!/bin/bash

#
# This is an example on how to start 2 nodes on the mainnet. 1 block-producing and 1 relay.
#

# Stop and remove existing nodes
docker stop cardano-main-relay && docker stop cardano-main-producing
docker rm cardano-main-relay && docker rm cardano-main-producing

# Create network so the nodes can see eachother.
docker network create cardano-main

# Start producing node
docker run -dit --rm \
    --network=cardano-main \
    -p 3000:3000 \
    -p 12788:12788 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="block-producing" \
    -e NODE_TOPOLOGY="cardano-main-relay:3001/1" \
    -e NODE_RELAY="False" \
    -e CARDANO_NETWORK="main" \
    -e EKG_PORT="12788" \
    -e PROMETHEUS_PORT="12798" \
    -e RESOLVE_HOSTNAMES="True" \
    -e REPLACE_EXISTING_CONFIG="True" \
    -v $PWD/active_config/main/block-producing:/config/ \
    --name cardano-main-producing \
    arrakis/cardano-node:pioneer --start

# Start relay node
docker run -dit --rm \
    --network=cardano-main \
    -p 3001:3001 \
    -p 12789:12789 \
    -p 12799:12799 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3001" \
    -e NODE_NAME="relay1" \
    -e NODE_TOPOLOGY="cardano-main-producing:3000/1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="main" \
    -e EKG_PORT="12789" \
    -e PROMETHEUS_PORT="12799" \
    -e RESOLVE_HOSTNAMES="True" \
    -e REPLACE_EXISTING_CONFIG="True" \
    -v $PWD/active_config/main/relay1:/config/ \
    --name cardano-main-relay \
    arrakis/cardano-node:pioneer --start

docker logs -f cardano-main-producing
