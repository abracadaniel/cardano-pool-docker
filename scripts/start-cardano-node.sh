#!/bin/bash

# Handle IP addresses
export PUBLIC_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [ ! -n "${PRODUCING_IP}" ]; then PRODUCING_IP=${PUBLIC_IP}; fi
if [ ! -n "${RELAY_IP}" ]; then RELAY_IP=${PUBLIC_IP}; fi

# Handle socket path. Producing socket will be changed if both nodes are run in the same container.
PRODUCING_SOCKET=${CARDANO_NODE_SOCKET_PATH}
RELAY_SOCKET=${CARDANO_NODE_SOCKET_PATH}

# Init config functions
function init_genesis_cfg {
    mkdir -p /config/${CARDANO_NETWORK}/
    if [ ! -f /config/${CARDANO_NETWORK}/genesis.json ]; then
        echo "Initializing ${CARDANO_NETWORK}/genesis.json"
        cp /config-templates/${CARDANO_NETWORK}/genesis.json /config/${CARDANO_NETWORK}/genesis.json
    fi
}

function init_blockproducing_cfg {
    mkdir -p /config/${CARDANO_NETWORK}/block-producing
    if [ ! -f /config/${CARDANO_NETWORK}/block-producing/topology.json ]; then
        echo "Initializing ${CARDANO_NETWORK}/block-producing/topology.json"
        cp /config-templates/${CARDANO_NETWORK}/block-producing/topology.json /config/${CARDANO_NETWORK}/block-producing/topology.json
        sed -i "s/\[RELAY_IP\]/${RELAY_IP}/g" /config/${CARDANO_NETWORK}/block-producing/topology.json
        sed -i "s/\[RELAY_PORT\]/${RELAY_PORT}/g" /config/${CARDANO_NETWORK}/block-producing/topology.json
    fi

    if [ ! -f /config/${CARDANO_NETWORK}/block-producing/config.json ]; then
        echo "Initializing ${CARDANO_NETWORK}/block-producing/config.json"
        cp /config-templates/${CARDANO_NETWORK}/block-producing/config.json /config/${CARDANO_NETWORK}/block-producing/config.json
    fi
}

function init_relay_cfg {
    mkdir -p /config/${CARDANO_NETWORK}/relay
    if [ ! -f /config/${CARDANO_NETWORK}/relay/topology.json ]; then
        echo "Initializing ${CARDANO_NETWORK}/relay/topology.json"
        cp /config-templates/${CARDANO_NETWORK}/relay/topology.json /config/${CARDANO_NETWORK}/relay/topology.json
        sed -i "s/\[PRODUCING_IP\]/${PRODUCING_IP}/g" /config/${CARDANO_NETWORK}/relay/topology.json
        sed -i "s/\[PRODUCING_PORT\]/${PRODUCING_PORT}/g" /config/${CARDANO_NETWORK}/relay/topology.json
    fi

    if [ ! -f /config/relay/config.json ]; then
        echo "Initializing ${CARDANO_NETWORK}/relay/config.json"
        cp /config-templates/${CARDANO_NETWORK}/relay/config.json /config/${CARDANO_NETWORK}/relay/config.json
    fi
}

function reset_genesis_cfg {
    rm -rf /config/${CARDANO_NETWORK}/genesis.json
}

function reset_producing_cfg {
    rm -rf /config/${CARDANO_NETWORK}/block-producing/topology.json
    rm -rf /config/${CARDANO_NETWORK}/block-producing/config.json
}

function reset_relay_cfg {
    rm -rf /config/${CARDANO_NETWORK}/relay/topology.json
    rm -rf /config/${CARDANO_NETWORK}/relay/config.json
}

function start_producing {
    init_blockproducing_cfg

    echo "Starting block-producing"
    cardano-node run \
        --topology /config/${CARDANO_NETWORK}/block-producing/topology.json \
        --database-path /config/${CARDANO_NETWORK}/block-producing/db \
        --socket-path ${PRODUCING_SOCKET} \
        --host-addr ${PRODUCING_IP} \
        --port ${PRODUCING_PORT} \
        --config /config/${CARDANO_NETWORK}/block-producing/config.json
}

function start_relay {
    init_relay_cfg

    echo "Starting relay node"
    cardano-node run \
        --topology /config/${CARDANO_NETWORK}/relay/topology.json \
        --database-path /config/${CARDANO_NETWORK}/relay/db \
        --socket-path ${RELAY_SOCKET} \
        --host-addr ${RELAY_IP} \
        --port ${RELAY_PORT} \
        --config /config/${CARDANO_NETWORK}/relay/config.json
}

function start_both {
    # Change socket path of producing
    PRODUCING_SOCKET="/producing.socket"

    start_producing &
    start_relay
}

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

function resolve_docker_hostname {
    # Convert hostname to IP address. Used for local docker instances to find eachother from container name.
    while true; do
        PRODUCING_REAL_IP=$(dig +short ${PRODUCING_IP})
        if [ -n "$PRODUCING_REAL_IP" ]; then
            PRODUCING_IP=${PRODUCING_REAL_IP} 
            break;
        fi
        echo "Cannot resolve ${PRODUCING_IP}..."
        sleep 1
    done

    while true; do
        RELAY_REAL_IP=$(dig +short ${RELAY_IP})
        if [ -n "$RELAY_REAL_IP" ]; then
            RELAY_IP=${RELAY_REAL_IP} 
            break;
        fi
        echo "Cannot resolve ${RELAY_IP}..."
        sleep 1
    done
}

function help {
    echo "Arguments:"
    echo "--resetproducing              Reset block-producing node config."
    echo "--resolve_docker_hostname     Resolve docker hostname to IP address in docker network."
    echo "--resetrelay                  Reset relay node config."
    echo "--resetgenesis                Reset genesis config."
    echo "--producing                   start block-producing node."
    echo "--relay                       start relay node."
    echo "--both                        start both block-producing and relay nodes."
    echo "--generate_key                Generate key and address."
    echo "--help                        see this message."
    echo "Environment variables:"
    echo "PRODUCING_IP                  IP address for the relay node to connect to the block-producing node. Defaults to public IP."
    echo "RELAY_IP                      IP address for the block-producing node to connect to the relay node. Defaults to public IP."
    exit
}

function node_info {
    echo "Running on ${CARDANO_NETWORK} network"
    echo "IP Addresses"
    echo "Public IP: ${PUBLIC_IP}"
    echo "Producing IP: ${PRODUCING_IP}"
    echo "Relay IP: ${RELAY_IP}"
}

for i in "$@"
do
case $i in
    --help)
        help
        break
    ;;
    --both)
        START_PRODUCING=1
        START_RELAY=1
    ;;
    --producing)
        START_PRODUCING=1
    ;;
    --relay)
        START_RELAY=1
    ;;
    --resetproducing)
        reset_producing_cfg
    ;;
    --resetrelay)
        reset_relay_cfg
    ;;
    --resetgenesis)
        reset_genesis_cfg
    ;;
    --resolve_docker_hostname)
        resolve_docker_hostname
    ;;
    --generate_key)
        generate_key
    ;;
    *)
        help
        break
    ;;
esac
done
if [ -z "$1" ]; then
    help
fi

if [ -n "$START_PRODUCING" ] || [ -n "$START_RELAY" ]; then
    # Display ip address info
    ip_info

    # Init configs
    init_genesis_cfg

    if [ -n "$START_PRODUCING" ] && [ -n "$START_RELAY" ]; then
        echo "Start block-producing and relay nodes"
        start_both
    elif [ -n "$START_PRODUCING" ]; then
        echo "Start block-producing node"
        start_producing
    elif [ -n "$START_RELAY" ]; then
        echo "Start relay node"
        start_relay
    fi
fi
