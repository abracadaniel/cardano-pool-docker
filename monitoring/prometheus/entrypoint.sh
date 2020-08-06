#!/bin/sh

# Init config
mkdir -p /config/
if [ ! -f "/config/config.yml" ]; then
    python /init_config.py /config.tmpl.yml /config/config.yml
fi

prometheus --config.file=/config/config.yml --storage.tsdb.path=/config/data/