# Running a Cardano Node

From the official [Node setup](https://github.com/input-output-hk/cardano-tutorials/tree/master/node-setup) and [pioneers-testnet](https://github.com/input-output-hk/cardano-tutorials/tree/master/pioneers-testnet) tutorials from IOHK.
The container downloads and builds the [cardano-node](https://github.com/input-output-hk/cardano-node.git) using the pioneer tag.
It can start either a block-producing node or a relay node, or both, and connect to the cardano network. By default it will connect to the Pioneer dev network, you can run on other networks using the CARDANO_NETWORK environment variable, See the [Environment variables](#environment) section.

## Usage

Here are some example snippets to help you get started creating a some nodes.
You will, by default, need to open to ports 3000 for the block-producing node and 3001 for the relay node.


### docker

#### block-producing node on pioneer dev net

```
docker run -dit --rm \
    -p 3000:3000 \
    -p 12788:12788 \
    -p 12798:12798 \
    -v </path/to/config>/:/config/ \
    -e CARDANO_NETWORK=pioneer \
    --name cardano-producing \
    cardano-node --producing # See arguments section for more options
```


#### relay node on pioneer dev net

```
docker run -dit --rm \
    -p 3001:3001 \
    -p 12789:12789 \
    -p 12799:12799 \
    -v </path/to/config>:/config/ \
    -e CARDANO_NETWORK=pioneer \
    --name cardano-relay \
    cardano-node --relay # See arguments section for more options
```


### docker-compose on pioneer dev net

This will run both a block-producing node and a relay node on the pioneer dev net.
```
version: "3"
services:
  cardano-prod: # block-producing node
    image: arrakis/cardano-node:pioneer
    container_name: cardano-prod
    volumes:
      - </path/to/config>:/config
    environment:
      - CARDANO_NETWORK=pioneer
    command: --producing # See arguments section for more options
    ports:
      - 3000:3000
      - 12788:12788 # For EKG
      - 12798:12798 # For Prometheus
    restart: unless-stopped
  cardano-relay: # relay node
    image: arrakis/cardano-node:pioneer
    container_name: cardano-relay
    volumes:
      - </path/to/config>:/config
    environment:
      - CARDANO_NETWORK=pioneer
    command: --relay # See arguments section for more options
    ports:
      - 3001:3001
      - 12789:12789 # For EKG
      - 12799:12799 # For Prometheus
    restart: unless-stopped
```


### docker-compose on pioneer byron main net

This will run both a block-producing node and a relay node on the byron main net.
```
version: "3"
services:
  cardano-prod: # block-producing node
    image: arrakis/cardano-node:pioneer
    container_name: cardano-prod
    volumes:
      - </path/to/config>:/config
    environment:
      - CARDANO_NETWORK=byron-main
    command: --producing
    ports:
      - 3000:3000
      - 12788:12788 # For EKG
      - 12798:12798 # For Prometheus
    restart: unless-stopped
  cardano-relay: # relay node
    image: arrakis/cardano-node:pioneer
    container_name: cardano-relay
    volumes:
      - </path/to/config>:/config
    environment:
      - CARDANO_NETWORK=byron-main
    command: --relay
    ports:
      - 3001:3001
      - 12789:12789 # For EKG
      - 12799:12799 # For Prometheus
    restart: unless-stopped
```


## Arguments
You can pass the following arguments to the start up script.

| Argument | Function |
| :-- | -- |
| --resolve_docker_hostname | Resolve docker hostname to IP address in docker network. |
| --resetproducing | Reset block-producing node config. |
| --resetrelay | Reset relay node config. |
| --resetgenesis | Reset genesis config. |
| --producing | start block-producing node. |
| --relay | start relay node. |
| --both | start both block-producing and relay nodes. |
| --generate_key | Generate key and address. |
| --help | see this message. |

## Environment variables <a id="environment"></a>
You can pass the following environment variables to the container.

| Variable | Function |
| :-- | -- |
| RELAY_IP | IP-address of relay node. Defaults to public IP |
| RELAY_PORT | Port of the relay node. Defaults to 3001. |
| PRODUCING_IP | IP-address of block-producing node. Defaults to public IP. |
| PRODUCING_PORT| Port of the block-producing node. Defaults to 3000. |
| CARDANO_NETWORK | Which network to run the nodes on. Defaults to pioneer. (Use byron-main for byron-main network). |

### Supported Networks
Use the CARDANO_NETWORK environment variable to change this.
The latest supported networks can be found at [https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html)

| Network | CARDANO_NETWORK value |
| :-- | -- |
| Pioneer dev net | pioneer |
| byron-mainnet | main |

## Ports
The ports to publish for the different nodes. For the nodes to work properly you need to forward the ports 3000 and 3001 to the instances running the nodes.
If you changes the ports using the environment variables, you will of course have to publish those ports.

| Port | Function |
| :-- | -- |
| 3000 | Default port block-producing node. |
| 12788 | EKG monitor port for block-producing. |
| 12798 | Prometheus monitoring port for block-producing node. |
| 3001  | Default port for relay node. |
| 12789 | EKG monitoring port for relay node. |
| 12799 | Prometheus monitoring port for relay node. |


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
| run-local-main.sh | Run nodes on byron-main net, and connect them using their local docker network addresses. |
| run-local-pioneer.sh | Run nodes on pioneer-dev net, and connect them using their local docker network addresses. |
| docker-compose-byronmain-public.yaml | Run nodes using docker-compose on byron-main net, and connect them using their public IP addresses. |
| docker-compose-pioneer-public.yaml | Run nodes using docker-compose on pioneer-dev net, and connect them using their public IP addresses. |
| stop-local.sh | Stops locally running containers. |


## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/abracadaniel/cardano-node-docker.git
cd cardano-node-docker
docker build -t droe/cardano-node:pioneer .
```


## Notes

The EKG and Prometheus monitoring services are currently not available, because they are locked to only allow access from localhost ip address (127.0.0.1).
This could be solved by adding a nginx reverse proxy, with authentication to the stack.
If you want to be able to access the EKG and Prometheus from outside the containers, you will currently have to run the containers on the `host` network.
