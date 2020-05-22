#!/bin/bash

CARDANO_NETWORK=$1
docker stop cardano-${CARDANO_NETWORK}-relay && docker stop cardano-${CARDANO_NETWORK}-producing
docker rm cardano-${CARDANO_NETWORK}-relay && docker rm cardano-${CARDANO_NETWORK}-producing
