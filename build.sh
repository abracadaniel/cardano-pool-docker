#!/bin/bash

VERSION="1.18.1"
docker build --build-arg CARDANO_BRANCH=tags/${VERSION} --build-arg VERSION=${VERSION} -t arrakis/cardano-node:${VERSION} -t arrakis/cardano-node:latest .
