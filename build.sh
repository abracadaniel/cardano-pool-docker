#!/bin/bash

MITHRIL_VERSION="2603.1"
NODE_VERSION="10.6.3"
LIBSODIUM_VERSION="dbb48cc"
ADDRESSES_VERSION="4.0.2"
BECH_VERSION="1.1.7"
CNCLI_VERSION="6.7.0"
POOL_VERSION="10.6.3"
DOCKER_USER="${DOCKER_USER:-arradev}"

echo "Building cardano-node:${NODE_VERSION}"
docker build -f Dockerfile.node \
    --progress=plain \
    --network=host \
    --build-arg LIBSODIUM_VERSION=${LIBSODIUM_VERSION} \
    --build-arg VERSION=${NODE_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/cardano-node:${NODE_VERSION} \
    --tag ${DOCKER_USER}/cardano-node:latest .

echo "Building mithril-client:${MITHRIL_VERSION}"
docker build -f Dockerfile.mithril-client \
    --network=host \
    --build-arg VERSION=${MITHRIL_VERSION} \
    --tag ${DOCKER_USER}/mithril-client:${MITHRIL_VERSION} \
    --tag ${DOCKER_USER}/mithril-client:latest .

echo "Building mithril-signer:${MITHRIL_VERSION}"
docker build -f Dockerfile.mithril-signer \
    --network=host \
    --build-arg VERSION=${MITHRIL_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/mithril-signer:${MITHRIL_VERSION} \
    --tag ${DOCKER_USER}/mithril-signer:latest .

echo "Building cardano-addresses:${ADDRESSES_VERSION}"
docker build -f Dockerfile.addresses \
    --network=host \
    --build-arg VERSION=${ADDRESSES_VERSION} \
    --tag ${DOCKER_USER}/cardano-addresses:${ADDRESSES_VERSION} \
    --tag ${DOCKER_USER}/cardano-addresses:latest .

echo "Building bech32:${BECH_VERSION}"
docker build -f Dockerfile.bech32 \
    --network=host \
    --build-arg VERSION=${BECH_VERSION} \
    --tag ${DOCKER_USER}/bech32:${BECH_VERSION} \
    --tag ${DOCKER_USER}/bech32:latest .

echo "Building cncli:${CNCLI_VERSION}"
docker build -f Dockerfile.cncli \
    --network=host \
    --build-arg VERSION=${CNCLI_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/cncli:${CNCLI_VERSION} \
    --tag ${DOCKER_USER}/cncli:latest .

echo "Building cardano-pool:${POOL_VERSION}"
docker build -f Dockerfile.pool \
    --network=host \
    --build-arg NODE_VERSION=${NODE_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/cardano-pool:${POOL_VERSION} \
    --tag ${DOCKER_USER}/cardano-pool:latest .