#!/bin/bash

MITHRIL_VERSION="2517.1"
NODE_VERSION="10.4.1"
LIBSODIUM_VERSION="dbb48cc"
ADDRESSES_VERSION="4.0.0"
BECH_VERSION="1.1.7"
CNCLI_VERSION="6.5.1"
POOL_VERSION="10.4.1-2"
DOCKER_USER="${DOCKER_USER:-arradev}"

docker build -f Dockerfile.node \
    --build-arg VERSION=${NODE_VERSION} \
    --tag ${DOCKER_USER}/cardano-node:${NODE_VERSION} \
    --tag ${DOCKER_USER}/cardano-node:latest .

docker build -f Dockerfile.mithril-client \
    --build-arg VERSION=${MITHRIL_VERSION} \
    --tag ${DOCKER_USER}/mithril-client:${MITHRIL_VERSION} \
    --tag ${DOCKER_USER}/mithril-client:latest .

docker build -f Dockerfile.mithril-signer \
    --build-arg VERSION=${MITHRIL_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/mithril-signer:${MITHRIL_VERSION} \
    --tag ${DOCKER_USER}/mithril-signer:latest .

docker build -f Dockerfile.addresses \
    --build-arg VERSION=${ADDRESSES_VERSION} \
    --tag ${DOCKER_USER}/cardano-addresses:${ADDRESSES_VERSION} \
    --tag ${DOCKER_USER}/cardano-addresses:latest .

docker build -f Dockerfile.bech32 \
    --build-arg VERSION=${BECH_VERSION} \
    --tag ${DOCKER_USER}/bech32:${BECH_VERSION} \
    --tag ${DOCKER_USER}/bech32:latest .

docker build -f Dockerfile.cncli \
    --build-arg VERSION=${CNCLI_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/cncli:${CNCLI_VERSION} \
    --tag ${DOCKER_USER}/cncli:latest .

docker build -f Dockerfile.pool \
    --build-arg NODE_VERSION=${NODE_VERSION} \
    --build-arg DOCKER_USER=${DOCKER_USER} \
    --tag ${DOCKER_USER}/cardano-pool:${POOL_VERSION} \
    --tag ${DOCKER_USER}/cardano-pool:latest .