#!/usr/bin/env bash

export JAVA_HOME=${JAVA_HOME}
export SPARK_LOCAL_IP="pc-core"
export SPARK_MASTER_IP="pc-core"
export SPARK_LOG_DIR=/pocket/log
export SPARK_LOCAL_DIRS=/pocket/tmp

# SPARK_WORKER_MEMORY is only used in standalone deploy mode
# 1 Worker (you can say 1 machine or 1 Worker Node) can launch multiple Executors
export SPARK_WORKER_MEMORY=1g
export SPARK_WORKER_OPTS="${SPARK_WORKER_OPTS} -Djava.awt.headless=true"

# SPARK_EXECUTOR_MEMORY is used in YARN deploy mode
#export SPARK_EXECUTOR_MEMORY=1g

# SPARK_DRIVER_MEMORY is used in YARN deploy mode
#export SPARK_DRIVER_MEMORY=4g

