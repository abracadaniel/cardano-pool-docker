#!/bin/sh

# Init config
echo "Generating config"
cp /nginx.tmpl.conf /config/nginx.conf
sed -i "s/\[PROMETHEUS_HOST\]/${PROMETHEUS_HOST}/g" /config/nginx.conf
cat /config/nginx.conf
echo ""

# Generate password
htpasswd -b -c /config/htpasswd ${USER} ${PASSWORD}

echo "Starting nginx"
nginx -g "daemon off;" -c /config/nginx.conf