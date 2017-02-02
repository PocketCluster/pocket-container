#!/usr/bin/env /bin/bash
source /root/.bashrc

set -ef

${HADOOP_HOME}/sbin/stop-dfs.sh
${HADOOP_HOME}/bin/hdfs dfsadmin -safemode wait