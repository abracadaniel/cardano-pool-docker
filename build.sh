#!/bin/bash

VERSION="1.18.0"
docker build --build-arg CARDANO_BRANCH=tags/${VERSION} -t arrakis/cardano-node:${VERSION} -t arrakis/cardano-node:latest .
