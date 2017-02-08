#!/bin/sh

if [ ! -d /usr/local/share/jupyter/certs/ ] || [ ! -f /usr/local/share/jupyter/certs/pc-core-jupyter.key ] || [ ! -f /usr/local/share/jupyter/certs/pc-core-jupyter.pem ]; then
    mkdir -p /usr/local/share/jupyter/certs/ 
    /usr/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /usr/local/share/jupyter/certs/pc-core-jupyter.key -out /usr/local/share/jupyter/certs/pc-core-jupyter.pem -subj "/O=PocketCluster/CN=pc-core"
fi