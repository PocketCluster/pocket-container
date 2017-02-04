#!/usr/bin/env /bin/bash
source /root/.bashrc

set -f

HADOOP_SLAVE="/etc/hadoop/slaves"

if [[ -f ${HADOOP_SLAVE} ]]; then
	rm ${HADOOP_SLAVE}
fi

if [ ! -d /pocket/hadoop/hdfs/datanode ] || [ ! -d /pocket/hadoop/log ]; then
    echo "Building datanode structure"
    mkdir -p /pocket/hadoop/hdfs/datanode
    mkdir -p /pocket/hadoop/log
fi
