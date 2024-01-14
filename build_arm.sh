#!/bin/bash

NODE_VERSION="8.7.2"
LIBSODIUM_VERSION="dbb48cc"
ADDRESSES_VERSION="3.12.0"
BECH_VERSION="1.1.4"
CNCLI_VERSION="5.3.2"
POOL_VERSION="8.7.2"

docker buildx build --platform linux/arm64 -f Dockerfile.node \
    --build-arg VERSION=${NODE_VERSION} \
    --tag arradev/cardano-node:${NODE_VERSION} \
    --tag arradev/cardano-node:latest .

docker buildx build --platform linux/arm64 -f Dockerfile.addresses \
    --build-arg VERSION=${ADDRESSES_VERSION} \
    --tag arradev/cardano-addresses:${ADDRESSES_VERSION} \
    --tag arradev/cardano-addresses:latest .

docker buildx build --platform linux/arm64 -f Dockerfile.bech32 \
    --build-arg VERSION=${BECH_VERSION} \
    --tag arradev/bech32:${BECH_VERSION} \
    --tag arradev/bech32:latest .

docker buildx build --platform linux/arm64 -f Dockerfile.cncli \
    --build-arg VERSION=${CNCLI_VERSION} \
    --tag arradev/cncli:${CNCLI_VERSION} \
    --tag arradev/cncli:latest .

docker buildx build --platform linux/arm64 -f Dockerfile.pool \
    --build-arg NODE_VERSION=${NODE_VERSION} \
    --tag arradev/cardano-pool:${POOL_VERSION} \
    --tag arradev/cardano-pool:latest .


