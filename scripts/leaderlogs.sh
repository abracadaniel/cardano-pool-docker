#!/bin/bash

source /scripts/init_node_vars

# Init vars
POOL_ID=$(cat ${NODE_PATH}/staking/POOL_ID)
TZ=$(cat /etc/timezone)
VRF=${NODE_PATH}/staking/pool-keys/vrf.skey
EPOCH=$1

# Get leaderlogs
python3 /scripts/pooltool.io/leaderLogs/leaderLogs.py \
    --vrf-skey ${VRF} \
    --pool-id ${POOL_ID} \
    --tz ${TZ} \
    --epoch ${EPOCH}
