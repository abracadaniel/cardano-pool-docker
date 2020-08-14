#!/bin/bash

VERSION="1.18.0"
docker build \
    --build-arg CARDANO_BRANCH=tags/${VERSION} \
    --build-arg VERSION=${VERSION} \
    --tag arrakis/cardano-node:${VERSION} \
    --tag arrakis/cardano-node:latest .
