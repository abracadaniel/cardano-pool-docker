#!/bin/bash

docker build --build-arg CARDANO_BRANCH=tags/pioneer -t arrakis/cardano-node:pioneer .
