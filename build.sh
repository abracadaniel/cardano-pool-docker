#!/bin/bash

MITHRIL_VERSION="2517.1"
NODE_VERSION="10.3.1"
LIBSODIUM_VERSION="dbb48cc"
ADDRESSES_VERSION="4.0.0"
BECH_VERSION="1.1.7"
CNCLI_VERSION="6.5.1"
POOL_VERSION="10.3.1"

docker build -f Dockerfile.node \
    --build-arg VERSION=${NODE_VERSION} \
    --tag arradev/cardano-node:${NODE_VERSION} \
    --tag arradev/cardano-node:latest .

docker build -f Dockerfile.mithril-client \
    --build-arg VERSION=${MITHRIL_VERSION} \
    --tag arradev/mithril-client:${MITHRIL_VERSION} \
    --tag arradev/mithril-client:latest .

docker build -f Dockerfile.mithril-signer \
    --build-arg VERSION=${MITHRIL_VERSION} \
    --tag arradev/mithril-signer:${MITHRIL_VERSION} \
    --tag arradev/mithril-signer:latest .

docker build -f Dockerfile.addresses \
    --build-arg VERSION=${ADDRESSES_VERSION} \
    --tag arradev/cardano-addresses:${ADDRESSES_VERSION} \
    --tag arradev/cardano-addresses:latest .

docker build -f Dockerfile.bech32 \
    --build-arg VERSION=${BECH_VERSION} \
    --tag arradev/bech32:${BECH_VERSION} \
    --tag arradev/bech32:latest .

docker build -f Dockerfile.cncli \
    --build-arg VERSION=${CNCLI_VERSION} \
    --tag arradev/cncli:${CNCLI_VERSION} \
    --tag arradev/cncli:latest .

docker build -f Dockerfile.pool \
    --build-arg NODE_VERSION=${NODE_VERSION} \
    --tag arradev/cardano-pool:${POOL_VERSION} \
    --tag arradev/cardano-pool:latest .