# Running a Cardano Stake Pool

Visit my stake pool @ [ada.arrakis.it](https://ada.arrakis.it).

From the official [cardano-node setup](https://docs.cardano.org/projects/cardano-node/en/latest/) tutorials from IOHK.
The container downloads and builds the [cardano-node](https://github.com/input-output-hk/cardano-node.git).
It can start either a block-producing node or a relay node, or both, and connect to the cardano network. By default it will connect to the test network, you can run on other networks using the CARDANO_NETWORK environment variable, See the [Environment variables](#environment) section.
If you want to run a stake pool, the block-producing container can take all the required steps to set up and register the stake pool.


## Steps in Running a Stake Pool

### The easy way

1. Upload your stake-pool metadata json file ([See example](#metadata-example)) to a host so it is accessible to the public. For example as a [github gist](https://gist.github.com/).
2. Start a relay node and make it connect to the block-producing node. See the [relay node example](#relay-example).
3. Start a block-producing node with the `--staking` argument and `CREATE_STAKEPOOL="True"` environment variable, and make it connect to the relay node. See the [block-producing node example](#producing-example)
4. Wait for the block-producing node to setup and register your pool.
5. Fund your payment address generated and displayed in Step 4 to finalize the registration.
6. Backup and remove the `cold-keys` directory from the `config` directory of the block-producing node.

The docker-compose file `examples/mc4-docker-compose.yaml` will run these 2 containers automatically.
Use the command `docker-compose -f mc4-docker-compose.yaml up` to start them.

**Warning:** These examples are ONLY for demonstration. The examples will run the nodes on the same server, using the `host` network, and connects to eachother using the localhost IP-address. This is not recommended. It is recommended to run the nodes on seperate servers and connect them using their public or local network IP-addresses. The idea is to keep the block-producing node completely locked off from anything other than the relay node. The block-producing node will also initialize and register the stake pool automatically, which is better to do on a seperate node, to keep the `cold-keys` directory away from the online nodes.


#### Renewing KES keys and certificates

To renew your KES keys and certificates you have to run the `generate_operational_certificate` command in the block-producing container.
The status window in the block-producing container will tell you when you have to generate new keys.

1. Start the command-line interface in the block-producing container containing the `cold-keys` directory. See `examples/mc4-producing-cli.sh`.
2. Run the `generate_operational_certificate` command and wait for it to complete.
3. Restart the block-producing container.


#### relay node on mainnet-candidate4 <a id="relay-example"></a>

See `examples/mc4-relay1.sh`.

```
docker run -it --rm \
    --network=host \
    --name mc4-relay1 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3001" \
    -e NODE_NAME="mc4-relay1" \
    -e NODE_RELAY="True" \
    -e NODE_TOPOLOGY="127.0.0.1:3000/1" \
    -e CARDANO_NETWORK="mc4" \
    -e EKG_PORT="12789" \
    -e PROMETHEUS_PORT="12799" \
    -e PROMETHEUS_HOST="127.0.0.1" \
    -e HOST_ADDR="0.0.0.0" \
    -v $PWD/config/local/:/config/ \
    arrakis/cardano-node:latest --start
```


#### block-producing node on mainnet-candidate4 <a id="producing-example"></a>

This will initialize and register the stakepool, and start the block-producing node.

See `examples/mc4-producing.sh`.

```
docker run -it --rm \
    --network=host \
    --name mc4-producing \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="mc4-block-producing" \
    -e NODE_TOPOLOGY="127.0.0.1:3001/1" \
    -e NODE_RELAY="False" \
    -e CARDANO_NETWORK="mc4" \
    -e EKG_PORT="12788" \
    -e PROMETHEUS_PORT="12798" \
    -e PROMETHEUS_HOST="127.0.0.1" \
    -e HOST_ADDR="0.0.0.0" \
    -e POOL_PLEDGE="100000000000" \
    -e POOL_COST="1000000000" \
    -e POOL_MARGIN="0.05" \
    -e CREATE_STAKEPOOL="True" \
    -e METADATA_URL="https://gist.githubusercontent.com/abracadaniel/58dfa2cfe0f986c7f445deb151ed1b49/raw/4bb8155af7be65d7e9869f0923c7ce778c75368b/metadata.json" \
    -e PUBLIC_RELAY_IP="PUBLIC" \
    -v $PWD/config/local/:/config/ \
    arrakis/cardano-node:latest --start --staking
```


### Best practice

This is an example on how to run your staking pool more securely, by keeping your `cold-keys` away from the online block-producing node.

For this setup you will need 3 hosts.
`host1` for running the relay node.
`host2` host for running the block-producing node.
`host3` host for generating and registering all the keys, addresses and certificates and storing the cold-keys for refreshing the KES keys and certificates. This can be a host you are running locally, with all incoming traffic completely shut off.

1. Upload your stake-pool metadata json file ([See example](#metadata-example)) to a host so it is accessible to the public. For example as a [github gist](https://gist.github.com/).
2. Start a relay node on `host1` and make it connect to the block-producing node on `host2`. See the [relay node example](#relay-example2).
3. Start a block-producing node on `host3`, with the `--staking` argument and `CREATE_STAKEPOOL="True"` environment variable, and make it connect to the relay node on `host1`. See the [registration node example](#registration-example2).
4. Fund your payment address generated and displayed in Step 3 to finalize the registration.
5. Wait for the block-producing node on `host3` to setup and register your pool.
6. Copy the `config/staking` directory, excluding the `cold-keys` directory, from the block-producing node on `host3` to the `config/staking` directory on `host2`.
7. Start a block-producing node on `host2`, with the `--staking` argument, and make it connect to the relay node on `host1`. See the [block-producing node example](#producing-example2).
8. Create Firewall rules for your block-producing node on `host3` to only accept incoming traffic from your relay node on `host1`.


#### Renewing KES keys and certificates

To renew your KES keys and certificates you have to run the `generate_operational_certificate` command in the registration container on `host3`
The status window in the block-producing container will tell you when you have to generate new keys.

1. Start the command-line interface in the registration container containing the `cold-keys` directory, on `host3`. Using `docker exec -it main-registration bash`.
2. Run the `generate_operational_certificate` command and wait for it to complete.
3. Copy the `config/staking/pool-keys/` directory on `host3` to the `config/staking/pool-keys/` directory on `host2`
4. Restart the block-producing container on `host2`.


#### relay node on mainnet <a id="relay-example2"></a>

Step 1. Run on `host1`. See `examples/main-relay1.sh`.

```
docker run -it --rm \
    --name main-relay1 \
    -p 3000:3000 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="relay1" \
    -e NODE_TOPOLOGY="<IP-address of block-producing node>:3000/1" \
    -e NODE_RELAY="True" \
    -e CARDANO_NETWORK="main" \
    -e PROMETHEUS_PORT="12798" \
    -v $PWD/config/:/config/ \
    arrakis/cardano-node:latest --start
```


#### registration node on mainnet <a id="registration-example2"></a>

Step 2. Run on `host3`. See `examples/main-registration.sh`.

```
docker run -it --rm \
    --name main-registration \
    -p 3000:3000 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="registration" \
    -e NODE_TOPOLOGY="<IP-address of relay1 node>:3000/1" \
    -e CARDANO_NETWORK="main" \
    -e CREATE_STAKEPOOL="True" \
    -e POOL_PLEDGE="100000000000" \
    -e POOL_COST="1000000000" \
    -e POOL_MARGIN="0.05" \
    -e METADATA_URL="<URL of metadata.json>" \
    -v $PWD/config/:/config/ \
    arrakis/cardano-node:latest --start --staking
```


#### block-producing node on mainnet <a id="producing-example2"></a>

Step 5. Run on `host2`. See `examples/main-producing.sh`.

```
docker run -it --rm \
    --name main-producing \
    -p 3000:3000 \
    -p 12798:12798 \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e NODE_PORT="3000" \
    -e NODE_NAME="block-producing" \
    -e NODE_TOPOLOGY="<IP-address of relay1 node>:3000/1" \
    -e CARDANO_NETWORK="main" \
    -e PROMETHEUS_PORT="12798" \
    -v $PWD/config/:/config/ \
    arrakis/cardano-node:latest --start --staking
```

#### Monitoring
If you want to monitor your nodes using prometheus across different hosts, you can set the environment variable `PROMETHEUS_HOST=0.0.0.0`. This makes the Prometheus service accessible to other hosts. So you can for example run a Prometheus+Grafana service on your relay node, scraping data from the block-producing and relay nodes.
If you do this, it is EXTREMELY important that you set up a Firewall rule ONLY allowing traffic from your relay nodes host on the Prometheus port, otherwise everyone will be able to monitor your node.

## Metadata example <a id="metadata-example"></a>

The `examples/metadata.json` file is the file that holds metadata about your pool.

It looks like the following, and has to be upload to a host so it is accessible to the public via. an URL.
You can for example upload it as a [github gist](https://gist.github.com).

```
{
    "name": "Example Pool",
    "description": "Cardano stakepool example",
    "ticker": "TEST",
    "homepage": "https://github.com/abracadaniel/cardano-node-docker"
}
```


## Arguments

You can pass the following arguments to the start up script.

| Argument | Function |
| :-- | -- |
| --start | Start node. |
| --staking | Start as a staking node (Requires the `--start` argument) |
| --cli | Start command-line interface. |
| --update | Update the node software. |
| --init_config | Initialize config. |
| --help | see this message. |


## Environment variables <a id="environment"></a>

You can pass the following environment variables to the container.

| Variable | Function |
| :-- | -- |
| PUID | User ID of user running the container |
| PGID | Group ID of user running the container |
| NODE_PORT | Port of node. Default: 3000. |
| NODE_NAME | Name of node. Default: node1. |
| NODE_TOPOLOGY | Topology of the node. Should be comma separated for each individual node to add, on the form: \<ip\>:\<port\>/\<valency\>. So for example: 127.0.0.1:3001/1,127.0.0.1:3002/1. |
| NODE_RELAY | Set to True if default IOHK relay should be added to the network topology. Default: False. |
| HOST_ADDR | Set cardano-node host address. Defaults to public IP address. |
| CARDANO_NETWORK | Carano network to use (main, test, pioneer). Default: main. |
| EKG_PORT | Port of EKG monitoring. Default: 12788. |
| PROMETHEUS_HOST | Host of Prometheus monitoring. Default: 127.0.0.1. |
| PROMETHEUS_PORT | Port of Prometheus monitoring. Default: 12798. |
| RESOLVE_HOSTNAMES | Resolve topology hostnames to IP-addresses. Default: False. |
| REPLACE_EXISTING_CONFIG | Reset and replace existing configs. Default: False. |
| CREATE_STAKEPOOL | Initializes Stake Pool keys, addresses and certificates, and sends them to the blockchain, when starting as a stakepool, if it is not already initialized. Default: False |
| POOL_PLEDGE | Pledge (lovelace). Default: 100000000000 |
| POOL_COST | Operational costs per epoch (lovelace). Default: 10000000000 |
| POOL_MARGIN | Operator margin. Default: 0.05 |
| METADATA_URL | URL for file containing stake pool metadata information. See \`examples/metadata.json\` for examle. The file be uploaded to an URL accessible to public. |
| PUBLIC_RELAY_IP | Public IP address of Relay node. <br/><br/>Values:<br/>\<Any IP address\><br/>TOPOLOGY: Use first entry of the topology.<br/>PUBLIC: Use public IP of node.<br/>Default: TOPOLOGY. |
| AUTO_TOPOLOGY | Automatically update topology.json. Default: True |


## Commands

These commands can be run from the command-line interface of the container.

| Command | Description |
| :-- | -- |
| create_stakepool | Take all the steps to initialize and register the stakepool from scratch. |
| generate_stake_address | Generate payment and stake keys and addresses. |
| generate_registration_certificates | Generates stakepool registration certificates. |
| generate_operational_certificates | Generates stakepool cold-keys, and VRF and KES keys, and the node certificates. |
| register_stake_address | Registers your stake address in the blockchain. |
| register_stake_pool | Registers your stake pool in the blockchain. |
| sync_status | Display node synchronization status. |


## Supported Networks

Use the CARDANO_NETWORK environment variable to change this.
The latest supported networks can be found at [https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html)

| Network | CARDANO_NETWORK value |
| :-- | -- |
| mainnet | main |
| mainnet-candidate4 | mc4 |


## Ports

| Port | Function |
| :-- | -- |
| 3000 | Default port cardano-node. |
| 12798 | Default port for Prometheus monitoring. |


## Volumes

| Volume | Function |
| :-- | -- |
| /config | Specify a folder to store the configuration and database of the nodes, for persistent data. |


## Example scripts

Use these example scripts to see how the nodes can be started. 

| Script | Description |
| :-- | -- |
| mc4-docker-compose.yaml | docker compose file for running relay node and block-producing node locally on mainnet-candidate4, and initialize and register the stakepool |
| mc4-relay1.sh | Run relay node locally on mainnet-candidate4. |
| mc4-producing.sh | Run block-producing node locally on mainnet-candidate4 and initialize and register the it as a stakepool. |
| main-relay1.sh | Run relay node locally on mainnet. |
| main-producing.sh | Run block-producing node on mainnet. |
| main-registration.sh | Run block-producing node on mainnet and initialize and register the it as a stakepool. |


## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic.

```
git clone https://github.com/abracadaniel/cardano-node-docker.git
cd cardano-node-docker
./build.sh
```


## Thank you

I hope you will find this useful. If you like the work please consider delegating to my pool:
`[ARRA1] Arrakis (c65ca06828caa8fc9b0bb015af93ef71685544c6ed2abbb7c59b0e62)`

or donating a few ADA to:
`addr1qyfdc9rkw2njpevpene998w93uyghftspnv6muxkwt82tyyjn4up3dddmmul3a5p98996dyd5nhn2mwthwce6rjrp0espmglvg`