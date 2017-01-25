#!/usr/bin/env /bin/bash
source ${HOME}/.bashrc

set -f

HADOOP_SLAVE="/etc/hadoop/slaves"
if [[ -f ${HADOOP_SLAVE} ]]; then
	rm ${HADOOP_SLAVE}
fi

# check hdfs structure
if [ "`ls -A /pocket`" == "" ]; then
  echo "Building datanode structure"
  mkdir -p /pocket/hdfs/namenode
  mkdir -p /pocket/hdfs/namenode2-checkpoint
  mkdir -p /pocket/hdfs/datanode
  mkdir -p /pocket/log
fi

# start sshd service
service ssh start
