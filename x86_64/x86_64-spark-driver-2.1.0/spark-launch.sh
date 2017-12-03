#!/usr/bin/env /bin/bash
source /root/.bashrc

set -ef

SPARK_SLAVE="/etc/spark/slaves"

if [[ -z ${CLUSTER_NAME} ]]; then
	echo "unknown cluster name"
	exit 2
fi

if [[ -z ${SLAVE_NODES} ]]; then
	echo "unknown slave nodes"
	exit 2
fi

if [[ -f ${SPARK_SLAVE} ]]; then
	rm ${SPARK_SLAVE}
fi

for slave in ${SLAVE_NODES//;/ }
do
	host=(${slave//=/ })
	if [[ -f ${SPARK_SLAVE} ]]; then
		echo ${host[0]} >> ${SPARK_SLAVE}
	else
		echo ${host[0]} > ${SPARK_SLAVE}
	fi
done

# check spark directories
if [ ! -d /pocket/spark/tmp ] || [ ! -d /pocket/spark/log ]; then
    echo "Formatting namenode name directory: /pocket/spark"
    mkdir -p /pocket/spark/tmp
    mkdir -p /pocket/spark/log
fi

${SPARK_HOME}/sbin/start-master.sh
sleep 2
${SPARK_HOME}/sbin/start-slaves.sh
sleep 2