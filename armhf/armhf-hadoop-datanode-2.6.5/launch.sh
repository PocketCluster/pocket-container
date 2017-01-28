#!/usr/bin/env /bin/bash
source /root/.bashrc

set -f

HADOOP_SLAVE="/etc/hadoop/slaves"

if [[ -f ${HADOOP_SLAVE} ]]; then
	rm ${HADOOP_SLAVE}
fi

if [ ! -d /pocket/hdfs/datanode ] || [ ! -d /pocket/log ]; then
    echo "Building datanode structure"
    mkdir -p /pocket/hdfs/datanode
    mkdir -p /pocket/log
fi
