#/usr/bin/env bash

if [ ! -f /usr/local/share/jupyter/certs/pc-core-jupyter.key ] || [ ! -f /usr/local/share/jupyter/certs/pc-core-jupyter.pem ]; then
    /usr/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /usr/local/share/jupyter/certs/pc-core-jupyter.key -out /usr/local/share/jupyter/certs/pc-core-jupyter.pem -subj "/O=PocketCluster/CN=pc-core" || true
fi