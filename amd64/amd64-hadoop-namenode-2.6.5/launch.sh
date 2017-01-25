#!/usr/bin/env /bin/bash
source ${HOME}/.bashrc

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

# check hdfs format
if [ "`ls -A /pocket`" == "" ]; then
  echo "Formatting namenode name directory: /pocket"
  mkdir -p /pocket/hdfs/namenode
  mkdir -p /pocket/hdfs/namenode2-checkpoint
  mkdir -p /pocket/log
  ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode -format ${CLUSTER_NAME}
fi

# start sshd service
service ssh start

${HADOOP_HOME}/sbin/start-dfs.sh
${HADOOP_HOME}/bin/hdfs dfsadmin -safemode wait
