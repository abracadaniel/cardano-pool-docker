#!/bin/bash

source /scripts/init_node_vars

# Init vars
ADDRESS=$(cat ${NODE_PATH}/staking/wallets/owner/payment.addr)

curl -v -XPOST "${FAUCET_URL}/${ADDRESS}?apiKey=${FAUCET_KEY}"