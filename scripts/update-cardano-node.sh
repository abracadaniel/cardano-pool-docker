#!/bin/bash

(cd /cardano-node \
    && git fetch --all --tags \
    && git tag \
    && git checkout tags/${CARDANO_TAG} \
    && cabal build all \
    && cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-node-1.11.0/x/cardano-node/build/cardano-node/cardano-node /usr/bin \
    && cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-1.11.0/x/cardano-cli/build/cardano-cli/cardano-cli /usr/bin)
