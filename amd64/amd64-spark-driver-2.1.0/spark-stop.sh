#!/usr/bin/env /bin/bash
source /root/.bashrc

set -ef

${SPARK_HOME}/sbin/stop-slaves.sh
sleep 2
${SPARK_HOME}/sbin/stop-master.sh
sleep 2