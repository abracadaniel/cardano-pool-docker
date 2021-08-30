import os
import shutil
import re
import argparse
import json
import socket
import time

CONFIG_TEMPLATES_ROOT_PATH = '/cfg-templates/'
CONFIG_OUTPUT_ROOT_PATH = '/config/'

def slugify(value):
    """
    Normalizes string, converts to lowercase, removes non-alpha characters,
    and converts spaces to hyphens.
    """
    value = re.sub('[^-a-zA-Z0-9_.]+', '', value)

    return value

def str2bool(v:str):
    """Converts string to boolean"""
    return v.lower() in ('yes', 'true', 't', '1')

def save_json(path:str, data):
	with open(path, 'w') as outfile:
		json.dump(data, outfile, indent=1)

def load_json(path:str):
    with open(path, 'r') as inputfile:
        return json.load(inputfile)

def init_args():
    # Parse arguments
    parser = argparse.ArgumentParser(description='Cardano Configurator')
    parser.add_argument('--node-port', dest='node_port', help='Port of node. Defaults to 3000.', type=int, default=os.environ.get('NODE_PORT', 3000))
    parser.add_argument('--node-name', dest='name', help='Name of node. Defaults to node1.', type=slugify, default=os.environ.get('NODE_NAME', 'node1'))
    parser.add_argument('--node-topology', dest='topology', help='Topology of the node. Should be comma separated for each individual node to add, on the form: <ip>:<port>/<valency>. So for example: 127.0.0.1:3001/1,127.0.0.1:3002/1.', type=str, default=os.environ.get('NODE_TOPOLOGY', ''))
    parser.add_argument('--node-relay', dest='relay', help='Set to 1 if default IOHK relay should be added to the network topology.', type=str2bool, default=os.environ.get('NODE_RELAY', False))
    parser.add_argument('--cardano-network', dest='network', help='Carano network to use (main, test, pioneer). Defaults to main.', type=str, default=os.environ.get('CARDANO_NETWORK', 'main'))
    parser.add_argument('--ekg-port', dest='ekg_port', help='Port of EKG monitoring. Defaults to 12788.', type=int, default=os.environ.get('EKG_PORT', 12788))
    parser.add_argument('--prometheus-host', dest='prometheus_host', help='Host of Prometheus monitoring. Defaults to 127.0.0.1.', type=str, default=os.environ.get('PROMETHEUS_HOST', '127.0.0.1'))
    parser.add_argument('--prometheus-port', dest='prometheus_port', help='Port of Prometheus monitoring. Defaults to 12798.', type=int, default=os.environ.get('PROMETHEUS_PORT', 12798))
    parser.add_argument('--resolve-hostnames', dest='resolve_hostnames', help='Resolve hostnames in topology to IP-addresses.', type=str2bool, default=os.environ.get('RESOLVE_HOSTNAMES', False))
    parser.add_argument('--replace-existing', dest='replace_existing', help='Replace existing configs.', type=str2bool, default=os.environ.get('REPLACE_EXISTING_CONFIG', False))  
    args = parser.parse_args()

    # Init network specific paths
    args.CONFIG_TEMPLATES_PATH = os.path.join(CONFIG_TEMPLATES_ROOT_PATH, args.network)
    CONFIG_NAME = args.network+'-'+args.name
    args.CONFIG_OUTPUT_PATH = os.path.join(CONFIG_OUTPUT_ROOT_PATH, CONFIG_NAME)
    args.BYRON_GENESIS_PATH = os.path.join(args.CONFIG_OUTPUT_PATH, 'byron-genesis.json')
    args.SHELLEY_GENESIS_PATH = os.path.join(args.CONFIG_OUTPUT_PATH, 'shelley-genesis.json')
    args.ALONZO_GENESIS_PATH = os.path.join(args.CONFIG_OUTPUT_PATH, 'alonzo-genesis.json')
    args.TOPOLOGY_PATH = os.path.join(args.CONFIG_OUTPUT_PATH, 'topology.json')
    args.CONFIG_PATH = os.path.join(args.CONFIG_OUTPUT_PATH, 'config.json')
    args.VARS_PATH = os.path.join(args.CONFIG_OUTPUT_PATH, 'VARS')

    return args

def init_folder(args):
    """Creates network/node config folders"""
    if not os.path.exists(args.CONFIG_OUTPUT_PATH):
        os.makedirs(args.CONFIG_OUTPUT_PATH)

def init_genesis(args):
    """Initializes the genesis file"""

    ALONZO_SRC = os.path.join(args.CONFIG_TEMPLATES_PATH, 'alonzo-genesis.json')
    SHELLEY_SRC = os.path.join(args.CONFIG_TEMPLATES_PATH, 'shelley-genesis.json')
    BYRON_SRC = os.path.join(args.CONFIG_TEMPLATES_PATH, 'byron-genesis.json')

    if not os.path.exists(args.ALONZO_GENESIS_PATH) or args.replace_existing:
        print('Generating new alonzo genesis file %s from template %s' % (args.ALONZO_GENESIS_PATH, ALONZO_SRC))
        shutil.copy(ALONZO_SRC, args.ALONZO_GENESIS_PATH)

    if not os.path.exists(args.SHELLEY_GENESIS_PATH) or args.replace_existing:
        print('Generating new shelley genesis file %s from template %s' % (args.SHELLEY_GENESIS_PATH, SHELLEY_SRC))
        shutil.copy(SHELLEY_SRC, args.SHELLEY_GENESIS_PATH)

    if not os.path.exists(args.BYRON_GENESIS_PATH) or args.replace_existing:
        print('Generating new byron genesis file %s from template %s' % (args.BYRON_GENESIS_PATH, BYRON_SRC))
        shutil.copy(BYRON_SRC, args.BYRON_GENESIS_PATH)


def resolve_hostname(hostname, tries=0):
    """Resolve IP from hostname"""
    try:
        return socket.gethostbyname(hostname)
    except:
        if tries<10:
            time.sleep(1)

            return resolve_hostname(hostname, tries=tries+1)
        else:
            return hostname

def parse_topology_str(s) -> list:
    """Parses node-topology string and returns list of dicts"""
    topology = []

    if s:
        for a in s.split(','):
            (ip_port, valency) = a.split('/')
            (ip, port) = ip_port.split(':')

            #if resolve_hostname: ip = resolve_hostname(ip)

            topology.append({
                'addr': str(ip),
                'port': int(port),
                'valency': int(valency)
            })

    return topology


def init_topology(args):
    """Initializes the topology file"""

    if args.relay:
        INPUT_PATH = os.path.join(args.CONFIG_TEMPLATES_PATH, 'topology-relay.json')
    else:
        INPUT_PATH = os.path.join(args.CONFIG_TEMPLATES_PATH, 'topology.json')

    if not os.path.exists(args.TOPOLOGY_PATH) or args.replace_existing:
        print('Generating new topology %s from template %s' % (args.TOPOLOGY_PATH, INPUT_PATH))
        print('Topology: ', args.topology)

        # Load template file
        data = load_json(INPUT_PATH)

        # Parse topology string
        topology = parse_topology_str(args.topology)

        # Add default IOHK relay

        data['Producers'] = data['Producers']+topology
        save_json(args.TOPOLOGY_PATH, data)

def init_config(args):
    """Initializes the config file"""

    INPUT_PATH = os.path.join(args.CONFIG_TEMPLATES_PATH, 'config.json')

    if not os.path.exists(args.CONFIG_PATH) or args.replace_existing:
        print('Generating new config file %s from template %s' % (args.CONFIG_PATH, INPUT_PATH))

        data = load_json(INPUT_PATH)
        data['hasEKG'] = args.ekg_port
        data['hasPrometheus'] = [args.prometheus_host, args.prometheus_port]
        data['ShelleyGenesisFile'] = args.SHELLEY_GENESIS_PATH
        data['ByronGenesisFile'] = args.BYRON_GENESIS_PATH
        data['AlonzoGenesisFile'] = args.ALONZO_GENESIS_PATH
        save_json(args.CONFIG_PATH, data)

def init_vars(args):
    INPUT_PATH = os.path.join(args.CONFIG_TEMPLATES_PATH, 'VARS')

    if not os.path.exists(args.VARS_PATH) or args.replace_existing:
        print('Generating new VARS %s from template %s' % (args.VARS_PATH, INPUT_PATH))

        # Just copy it
        shutil.copy(INPUT_PATH, args.VARS_PATH)

if __name__ == '__main__':
    args = init_args()

    init_folder(args)
    init_genesis(args)
    init_topology(args)
    init_config(args)
    #init_vars(args)
