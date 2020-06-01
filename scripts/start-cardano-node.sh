#!/bin/bash

# Handle IP addresses
export PUBLIC_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
export NODE_PATH=/config/${CARDANO_NETWORK}/${NODE_NAME}/

function generate_key {
    UNIXTIME=$(date +%s%N)
    RAND=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    ADDRESS=${RAND}_${UNIXTIME}
    mkdir -p /config/${CARDANO_NETWORK}/keys/${ADDRESS}

    (cd /config/${CARDANO_NETWORK}/keys/${ADDRESS} \
        && cardano-cli shelley address key-gen \
            --verification-key-file payment.vkey \
            --signing-key-file payment.skey \
        && ADDR=$(cardano-cli shelley address build-enterprise \
            --payment-verification-key-file payment.vkey) \
        && echo ${ADDR} > ${ADDR}.addr)
}

function help {
    echo "Arguments:"
    echo "--start                       Start node"
    echo "--update                      Update the node software."
    echo "--generate_key                Generate key and address."
    echo "--help                        Display this message."
    echo "Environment variables:"
    echo "NODE_PORT                     Port of node. Default: 3000."
    echo "NODE_NAME                     Name of node. Default: node1."
    echo "NODE_TOPOLOGY                 Topology of the node. Should be comma separated for each individual node to add, on the form: <ip>:<port>/<valency>. So for example: 127.0.0.1:3001/1,127.0.0.1:3002/1."
    echo "NODE_RELAY                    Set to True if default IOHK relay should be added to the network topology. Default: False."
    echo "CARDANO_NETWORK               Carano network to use (main, test, pioneer). Default: main."
    echo "EKG_PORT                      Port of EKG monitoring. Default: 12788."
    echo "PROMETHEUS_PORT               Port of Prometheus monitoring. Default: 12798."
    echo "RESOLVE_HOSTNAMES             Resolve topology hostnames to IP-addresses. Default: False."
    echo "REPLACE_EXISTING_CONFIG       Reset and replace existing configs. Default: False."

    exit
}

function node_info {
    echo "Running cardano-node on ${CARDANO_NETWORK} network"
    echo "Node name: ${NODE_NAME}"
    echo "Public IP: ${PUBLIC_IP}"
    echo "Node Port: ${NODE_PORT}"
    echo "Node path: ${NODE_PATH}"
    echo "EKG Port: ${EKG_PORT}"
    echo "Prometheus Port: ${PROMETHEUS_PORT}"

}

function init_config {
    python3 /scripts/init_config.py
}

function start_node {
    echo "Starting cardano-node"
    node_info
    init_config
    cardano-node run \
        --topology ${NODE_PATH}/topology.json \
        --database-path ${NODE_PATH}/db \
        --socket-path ${NODE_PATH}/node.socket \
        --host-addr 0.0.0.0 \
        --port ${NODE_PORT} \
        --config ${NODE_PATH}/config.json
}

for i in "$@"
do
case $i in
    --help)
        help
        break
    ;;
    --update)
        /scripts/update-cardano-node.sh
    ;;
    --generate_key)
        generate_key
    ;;
    --start)
        START_NODE=1
    ;;
    *)
        break
    ;;
esac
done
if [ -z "$1" ]; then
    help
fi

if [ -n "$START_NODE" ]; then
    start_node
fi
