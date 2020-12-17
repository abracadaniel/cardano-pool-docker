#!/bin/bash

# Init vars
POOL_ID=$(cat ${NODE_PATH}staking/POOL_ID)
TZ=$(cat /etc/timezone)
VRF=${NODE_PATH}staking/pool-keys/vrf.skey

echo "Dumping ledger.json"
cardano-cli shelley query ledger-state --mainnet --out-file ${NODE_PATH}ledger.json

echo "Calculating sigma"
SIGMA=$(python3 /scripts/pooltool.io/leaderLogs/getSigma.py --pool-id ${POOL_ID} --ledger ${NODE_PATH}ledger.json | tail -1 | awk '{print $2}')

# Print vars
echo "POOL_ID: ${SIGMA}"
echo "TZ: ${TZ}"
echo "VRF: ${VRF}"
echo "SIGMA: ${SIGMA}"

# Get leaderlogs
python3 /scripts/pooltool.io/leaderLogs/leaderLogs.py \
    --vrf-skey ${VRF} \
    --sigma ${SIGMA} \
    --tz ${TZ}
