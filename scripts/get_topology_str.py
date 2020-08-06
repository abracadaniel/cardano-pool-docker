import os
from init_config import parse_topology_str

if __name__ == '__main__':
    topology = parse_topology_str(os.environ.get('NODE_TOPOLOGY', ''))

    _topology = []
    for t in topology:
        _topology.append('%s:%s:%s' % (t.get('addr'), t.get('port'), t.get('valency')))
    print('|'.join(_topology))