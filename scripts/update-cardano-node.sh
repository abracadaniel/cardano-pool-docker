#!/bin/bash

(cd /root/cardano-node \
    && git fetch --all --tags \
    && git tag \
    && git checkout tags/${CARDANO_TAG} \
    && cabal install cardano-node cardano-cli)
