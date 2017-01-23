#!/usr/bin/env /bin/bash
source ${HOME}/.bashrc

set -f

ETC_HOSTS="/etc/hosts"
HADOOP_SLAVE="/etc/hadoop/slaves"

if [[ -z ${MASTER_NODE} ]]; then
	echo "unknown master node"
	exit 2
else
	master=(${MASTER_NODE//=/ })
	if [[ -f ${ETC_HOSTS} ]]; then
		echo ${master[1]} ${master[0]} >> ${ETC_HOSTS}
	else
		echo ${master[1]} ${master[0]} > ${ETC_HOSTS}
	fi	
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
	if [ "${HOSTNAME}" == "${host[0]}" ]; then
		continue
	fi
	if [[ -f ${ETC_HOSTS} ]]; then
		echo ${host[1]} ${host[0]} >> ${ETC_HOSTS}
	else
		echo ${host[1]} ${host[0]} > ${ETC_HOSTS}
	fi
:<<SLAVE	
	if [[ -f ${HADOOP_SLAVE} ]]; then
		echo ${host[0]} >> ${HADOOP_SLAVE}
	else
		echo ${host[0]} > ${HADOOP_SLAVE}
	fi
SLAVE
done

# start sshd service
service ssh start
