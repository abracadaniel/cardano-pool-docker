#!/bin/bash

VERSION="1.27.0"
docker build \
    --build-arg VERSION=${VERSION} \
    --tag arradev/cardano-node:${VERSION} \
    --tag arradev/cardano-node:latest .
