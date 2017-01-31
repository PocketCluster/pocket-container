#!/usr/bin/env /bin/bash
source /root/.bashrc

# check spark directories
if [ ! -d /pocket/spark/tmp ] || [ ! -d /pocket/spark/log ]; then
    echo "Building spark directory structure: /pocket/spark"
    mkdir -p /pocket/spark/tmp
    mkdir -p /pocket/spark/log
fi
