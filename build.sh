#!/bin/bash

VERSION="1.21.1"
docker build \
    --build-arg VERSION=${VERSION} \
    --tag arradev/cardano-node:${VERSION} \
    --tag arradev/cardano-node:latest .
