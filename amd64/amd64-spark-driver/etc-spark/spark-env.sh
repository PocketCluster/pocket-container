#!/usr/bin/env bash

export JAVA_HOME=${JAVA_HOME}
export HADOOP_CONF_DIR=/etc/hadoop
export SPARK_LOCAL_IP="{{ grains['nodename'] }}"
export SPARK_WORKER_INSTANCES=1
export SPARK_EXECUTOR_MEMORY=1g
export SPARK_WORKER_MEMORY=1g
export SPARK_WORKER_OPTS="${SPARK_WORKER_OPTS} -Djava.awt.headless=true"
export SPARK_MASTER_IP="pc-master"
export SPARK_LOG_DIR=/pocket/log
export SPARK_LOCAL_DIRS=/pocket/work