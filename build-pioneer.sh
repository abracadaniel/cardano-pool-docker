#!/bin/bash

docker build --build-arg CARDANO_BRANCH=tags/pioneer-wave2 -t arrakis/cardano-node:pioneer2 .
