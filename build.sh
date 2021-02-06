#!/bin/bash

VERSION="1.25.1"
docker build \
    --build-arg VERSION=${VERSION} \
    --tag arradev/cardano-node:${VERSION} \
    --tag arradev/cardano-node:latest .
