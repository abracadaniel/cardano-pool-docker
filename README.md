# Running a Cardano Node

From the official [Node setup](https://github.com/input-output-hk/cardano-tutorials/tree/master/node-setup) and [pioneers-testnet](https://github.com/input-output-hk/cardano-tutorials/tree/master/pioneers-testnet) tutorials from IOHK.
The container downloads and builds the [cardano-node](https://github.com/input-output-hk/cardano-node.git) using the pioneer tag.
It can start either a block-producing node or a relay node, or both, and connect to the cardano network. By default it will connect to the Pioneer dev network, you can run on other networks using the CARDANO_NETWORK environment variable, See the [Environment variables](#environment) section.

## Usage

Here are some example snippets to help you get started creating a some nodes.
You will, by default, need to open the port 3000 for the block-producing node and 3001 for the relay node.


## Block producers and Relays
For information on block producer and relay nodes read the official documentation [Block producers and Relays](https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/topology.md)

### docker

### Create shared network for containers

This creates a docker network for the containers, so the containers can communicate with eachother.

```
docker network create cardano-pioneer
```


#### block-producing node on pioneer net

```
docker run -dit --rm \
    --network=cardano-pioneer \
    -p 3000:3000 \
    -p 12788:12788 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="block-producing" \
    -e NODE_TOPOLOGY="cardano-pioneer-relay:3001/1" \
    -e NODE_RELAY="False" \
    -e CARDANO_NETWORK="pioneer" \
    -e EKG_PORT="12788" \
    -e PROMETHEUS_PORT="12798" \
    -e RESOLVE_HOSTNAMES="True" \
    -e REPLACE_EXISTING_CONFIG="True" \
    -v </path/to/config>:/config/ \
    --name cardano-pioneer-producing \
    arrakis/cardano-node:pioneer --start
```


#### relay node on pioneer net

```
docker run -dit --rm \
    --network=cardano-pioneer \
    -p 3001:3001 \
    -p 12789:12789 \
    -p 12799:12799 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3001" \
    -e NODE_NAME="relay" \
    -e NODE_TOPOLOGY="cardano-pioneer-producing:3000/1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="pioneer" \
    -e EKG_PORT="12789" \
    -e PROMETHEUS_PORT="12799" \
    -e RESOLVE_HOSTNAMES="True" \
    -e REPLACE_EXISTING_CONFIG="True" \
    -v </path/to/config>:/config/ \
    --name cardano-pioneer-relay \
    arrakis/cardano-node:pioneer --start
```


### docker-compose on pioneer mainnet

This will run both a block-producing node and a relay node on the byron main net.

```
version: "3"
services:
  cardano-byron-producing: # block-producing node
    image: arrakis/cardano-node:pioneer
    container_name: cardano-main-producing
    network_mode: host
    volumes:
      - $PWD/active_config/:/config
    environment:
      - PUID=1000
      - PGID=1001
      - NODE_PORT=3000
      - NODE_NAME=block-producing
      - NODE_TOPOLOGY=127.0.0.1:3001/1
      - NODE_RELAY=False
      - CARDANO_NETWORK=main
      - EKG_PORT=12788
      - PROMETHEUS_PORT=12798
      - RESOLVE_HOSTNAMES=True
      - REPLACE_EXISTING_CONFIG=True
    command: --start
    restart: unless-stopped
  cardano-byron-relay: # relay node
    image: arrakis/cardano-node:pioneer
    container_name: cardano-main-relay
    network_mode: host
    volumes:
      - $PWD/active_config/:/config
    environment:
      - PUID=1000
      - PGID=1001
      - NODE_PORT=3001
      - NODE_NAME=relay
      - NODE_TOPOLOGY=127.0.0.1:3000/1
      - NODE_RELAY=True
      - CARDANO_NETWORK=main
      - EKG_PORT=12789
      - PROMETHEUS_PORT=12799
      - RESOLVE_HOSTNAMES=True
      - REPLACE_EXISTING_CONFIG=True
    command: --start
    restart: unless-stopped
```


## Arguments

You can pass the following arguments to the start up script.

| Argument | Function |
| :-- | -- |
| --start | Start node. |
| --update | Update the node software. |
| --generate_key | Generate key and address. |
| --help | see this message. |


## Environment variables <a id="environment"></a>

You can pass the following environment variables to the container.

| Variable | Function |
| :-- | -- |
| PUID | User ID of user running the container |
| PGID | Group ID of user running the container |
| NODE_PORT | Port of node. Default: 3000. |
| NODE_NAME | Name of node. Default: node1. |
| NODE_TOPOLOGY | Topology of the node. Should be comma separated for each individual node to add, on the form: <ip>:<port>/<valency>. So for example: 127.0.0.1:3001/1,127.0.0.1:3002/1. |
| NODE_RELAY | Set to True if default IOHK relay should be added to the network topology. Default: False. |
| CARDANO_NETWORK | Carano network to use (main, test, pioneer). Default: main. |
| EKG_PORT | Port of EKG monitoring. Default: 12788. |
| PROMETHEUS_PORT | Port of Prometheus monitoring. Default: 12798. |
| RESOLVE_HOSTNAMES | Resolve topology hostnames to IP-addresses. Default: False. |
| REPLACE_EXISTING_CONFIG | Reset and replace existing configs. Default: False. |


### Supported Networks

Use the CARDANO_NETWORK environment variable to change this.
The latest supported networks can be found at [https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html)

| Network | CARDANO_NETWORK value |
| :-- | -- |
| Pioneer dev net | pioneer |
| byron-mainnet | main |
| testnet | test |


## Ports

The ports to publish for the different nodes. For the nodes to work properly you need to forward the ports 3000 and 3001 to the instances running the nodes.
If you changes the ports using the environment variables, you will of course have to publish those ports.

| Port | Function |
| :-- | -- |
| 3000 | Default port block-producing node. |
| 12788 | Default port for EKG monitoring. |
| 12798 | Default port for Prometheus monitoring. |


## Volumes

| Volume | Function |
| :-- | -- |
| /config | Specify a folder to store the configuration and database of the nodes, for persistent data. |


## Example scripts

Use these example scripts to see how the nodes can be started. 

| Script | Description |
| :-- | -- |
| build.sh | Build the container locally.|
| run-local-cli.sh | Run interactive cli shell. | 
| run-local-main.sh | Run nodes on mainnet, and connect them using their local docker network addresses. |
| docker-compose-main.yaml | Run nodes using docker-compose on mainnet. |
| docker-compose-pioneer.yaml | Run nodes using docker-compose on pioneer-dev net. |
| stop-local.sh | Stops locally running containers. |


## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/abracadaniel/cardano-node-docker.git
cd cardano-node-docker
docker build -t arrakis/cardano-node:pioneer .
```


## Notes

The EKG and Prometheus monitoring services are currently not available, because they are locked to only allow access from localhost ip address (127.0.0.1).
This could be solved by adding a nginx reverse proxy, with authentication to the stack.
If you want to be able to access the EKG and Prometheus from outside the containers, you will currently have to run the containers on the `host` network.
