#!/bin/bash

source /scripts/init_node_vars

# Init vars
POOL_ID=$(cat ${NODE_PATH}/staking/POOL_ID)
TZ=$(cat /etc/timezone)
VRF=${NODE_PATH}/staking/pool-keys/vrf.skey
SNAPSHOT=${NODE_PATH}/stake_snapshot.json
LEADERLOG=${NODE_PATH}/leaderlog.json
LSET="${1:-current}"

case ${LSET} in
  prev|current|next) echo "Running leaderlogs for ${LSET} epoch" ;;
  *)                 echo "Invalid argument. Must be either prev|current|next"; exit ;;
esac

# Get stake snapshot
cardano-cli query stake-snapshot \
  --stake-pool-id ${POOL_ID} \
  --mainnet > ${SNAPSHOT}

case ${LSET} in
  prev)
    POOL_STAKE=$(cat $SNAPSHOT | jq .poolStakeGo)
    ACTIVE_STAKE=$(cat $SNAPSHOT | jq .activeStakeGo)
    ;;
  current)
    POOL_STAKE=$(cat $SNAPSHOT | jq .poolStakeSet)
    ACTIVE_STAKE=$(cat $SNAPSHOT | jq .activeStakeSet)
    ;;
  next)
    ACTIVE_STAKE=$(cat $SNAPSHOT | jq .activeStakeMark)
    POOL_STAKE=$(cat $SNAPSHOT | jq .poolStakeMark)
    ;;
esac

# Get leaderlogs
cncli leaderlog \
  --byron-genesis ${NODE_PATH}/byron-genesis.json \
  --shelley-genesis ${NODE_PATH}/shelley-genesis.json \
  --pool-id ${POOL_ID} \
  --pool-vrf-skey ${VRF} \
  --ledger-set ${LSET} \
  --active-stake ${ACTIVE_STAKE} \
  --pool-stake ${POOL_STAKE} \
  --tz ${TZ} \
  --db ${NODE_PATH}/cncli.db | tee ${LEADERLOG}
