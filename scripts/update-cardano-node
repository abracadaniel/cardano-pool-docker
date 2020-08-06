#!/bin/bash

NODE_PATH=/config/${CARDANO_NETWORK}/${NODE_NAME}/
CARDANO_BRANCH=$(cat /CARDANO_BRANCH)

(cd ~/.cabal/bin/ && rm -rf cardano-node cardano-cli chairman) # Remove old files
rm -rf ${NODE_PATH}/db/ # Remove database

(cd /cardano-node \
    && git fetch --all --tags \
    && git tag \
    && git checkout ${CARDANO_BRANCH} \
    && cabal install cardano-node cardano-cli) 
