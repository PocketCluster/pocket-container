#!/usr/bin/env /bin/bash
source /root/.bashrc

set -f

HADOOP_SLAVE="/etc/hadoop/slaves"

if [[ -z ${CLUSTER_NAME} ]]; then
	echo "unknown cluster name"
	exit 2
fi

if [[ -z ${SLAVE_NODES} ]]; then
	echo "unknown slave nodes"
	exit 2
fi

if [[ -f ${HADOOP_SLAVE} ]]; then
	rm ${HADOOP_SLAVE}
fi

for slave in ${SLAVE_NODES//;/ }
do
	host=(${slave//=/ })
	if [[ -f ${HADOOP_SLAVE} ]]; then
		echo ${host[0]} >> ${HADOOP_SLAVE}
	else
		echo ${host[0]} > ${HADOOP_SLAVE}
	fi
done

service ssh start

# check hdfs format
if [ ! -d /pocket/hadoop/hdfs/namenode ] || [ ! -d /pocket/hadoop/hdfs/namenode2-checkpoint ] || [ ! -d /pocket/hadoop/log ]; then
    echo "Formatting namenode name directory: /pocket"
    mkdir -p /pocket/hadoop/hdfs/namenode
    mkdir -p /pocket/hadoop/hdfs/namenode2-checkpoint
    mkdir -p /pocket/hadoop/log
    ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode -format ${CLUSTER_NAME}
fi

${HADOOP_HOME}/sbin/start-dfs.sh
${HADOOP_HOME}/bin/hdfs dfsadmin -safemode wait