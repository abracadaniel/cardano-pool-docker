#!/bin/bash

docker run -it --rm \
    --network=host \
    --name mc4-producing \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="mc4-block-producing" \
    -e NODE_TOPOLOGY="127.0.0.1:3001/1" \
    -e NODE_RELAY="False" \
    -e CARDANO_NETWORK="mc4" \
    -e EKG_PORT="12788" \
    -e PROMETHEUS_PORT="12798" \
    -e PROMETHEUS_HOST="127.0.0.1" \
    -e HOST_ADDR="0.0.0.0" \
    -e POOL_PLEDGE="100000000000" \
    -e POOL_COST="1000000000" \
    -e POOL_MARGIN="0.05" \
    -e CREATE_STAKEPOOL="True" \
    -e METADATA_URL="https://gist.githubusercontent.com/abracadaniel/58dfa2cfe0f986c7f445deb151ed1b49/raw/4bb8155af7be65d7e9869f0923c7ce778c75368b/metadata.json" \
    -e PUBLIC_RELAY_IP="PUBLIC" \
    -v $PWD/config/local/:/config/ \
    arrakis/cardano-node:latest --start --staking