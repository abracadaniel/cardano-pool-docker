import os
import yaml
import sys


def parse_targets(targets_str):
    if not targets_str: return None

    output = []
    targets = targets_str.split(',')
    for target in targets:
        alias, host = target.split('/')
        addr, port = host.split(':')
        
        output.append({
            'targets': ['%s:%s' % (addr, port)],
            'labels': {
                'alias': alias,
                'type': 'cardano-node'
            }
        })
    return output

in_file = sys.argv[1]
out_file = sys.argv[2]
targets = parse_targets(os.environ.get('TARGETS'))
if targets:
    with open(in_file) as file:
        config = yaml.full_load(file)
        print(config)
        print(targets)
        config['scrape_configs'][0]['static_configs'] = targets

        with open(out_file, 'w') as _file:
            documents = yaml.dump(config, _file)