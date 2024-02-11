#!/bin/bash

set -e

source /config/mithril/config.env

if [ -z "$AGGREGATOR_ENDPOINT" ] || [ -z "$PARTY_ID" ]; then
    echo ">> ERROR: Required environment variables AGGREGATOR_ENDPOINT and/or PARTY_ID are not set."
    exit 1
fi

CURRENT_EPOCH=$(curl -s "$AGGREGATOR_ENDPOINT/epoch-settings" -H 'accept: application/json' | jq -r '.epoch')
SIGNERS_REGISTERED_RESPONSE=$(curl -s "$AGGREGATOR_ENDPOINT/signers/registered/$CURRENT_EPOCH" -H 'accept: application/json')

if echo "$SIGNERS_REGISTERED_RESPONSE" | grep -q "$PARTY_ID"; then
    echo ">> Congrats, your signer node is registered!"
else
    echo ">> Oops, your signer node is not registered. Party ID not found among the signers registered at epoch ${CURRENT_EPOCH}."
fi
