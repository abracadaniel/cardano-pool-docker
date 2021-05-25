#!/bin/bash

source /scripts/init_node_vars

# Init vars
POOL_ID=$(cat ${NODE_PATH}/staking/POOL_ID)
TZ=$(cat /etc/timezone)
VRF=${NODE_PATH}/staking/pool-keys/vrf.skey
LSET=$1

# Ledger dump
#cardano-cli query ledger-state --mainnet > /ledger.json

# Get leaderlogs
echo "Running leaderlogs"
cncli leaderlog \
    --byron-genesis ${NODE_PATH}/byron-genesis.json \
    --shelley-genesis ${NODE_PATH}/shelley-genesis.json \
    --pool-id ${POOL_ID} \
    --pool-vrf-skey ${VRF} \
    --ledger-state /ledger.json \
    --ledger-set ${LSET} \
    --tz ${TZ}
