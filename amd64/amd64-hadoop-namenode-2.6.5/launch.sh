#!/usr/bin/env /bin/bash
source ${HOME}/.bashrc

set -f

ETC_HOSTS="/etc/hosts"
HADOOP_SLAVE="/etc/hadoop/slaves"

if [[ -z ${SLAVE_NODES} ]]; then
	echo "unknown slave nodes"
	exit 2
fi
if [[ -z ${CLUSTER_NAME} ]]; then
	echo "unknown cluster name"
	exit 2
fi
if [[ -f ${HADOOP_SLAVE} ]]; then
	rm ${HADOOP_SLAVE}
fi
for slave in ${SLAVE_NODES//;/ }
do
	host=(${slave//=/ })
	if [[ -f ${ETC_HOSTS} ]]; then
		echo ${host[1]} ${host[0]} >> ${ETC_HOSTS}
	else
		echo ${host[1]} ${host[0]} > ${ETC_HOSTS}
	fi
	if [[ -f ${HADOOP_SLAVE} ]]; then
		echo ${host[0]} >> ${HADOOP_SLAVE}
	else
		echo ${host[0]} > ${HADOOP_SLAVE}
	fi
done

# start sshd service
service ssh start

# check hdfs format
if [ "`ls -A /pocket`" == "" ]; then
  echo "Formatting namenode name directory: /pocket"
  ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode -format ${CLUSTER_NAME}
  ${HADOOP_HOME}/sbin/start-dfs.sh
  ${HADOOP_HOME}/bin/hdfs dfsadmin -safemode wait
  ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/"${USER}"
  ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp
  ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /jobhistory/tmp
  ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /jobhistory/done
  ${HADOOP_HOME}/bin/hdfs dfs -chmod -R 1777 /jobhistory/tmp
  ${HADOOP_HOME}/bin/hdfs dfs -chmod -R 1777 /jobhistory/done
  ${HADOOP_HOME}/sbin/stop-dfs.sh
fi

${HADOOP_HOME}/sbin/start-dfs.sh
#${HADOOP_HOME}/sbin/mr-jobhistory-daemon.sh start historyserver
${HADOOP_HOME}/bin/hdfs dfsadmin -safemode wait
