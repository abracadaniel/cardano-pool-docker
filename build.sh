#!/bin/bash

VERSION="1.24.2"
docker build \
    --build-arg VERSION=${VERSION} \
    --tag arradev/cardano-node:${VERSION} \
    --tag arradev/cardano-node:latest .
