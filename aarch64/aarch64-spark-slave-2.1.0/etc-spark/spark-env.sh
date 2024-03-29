#!/usr/bin/env bash

export JAVA_HOME=${JAVA_HOME}

### Options read when launching programs locally with ./bin/run-example or ./bin/spark-submit ###
# To point Spark towards Hadoop configuration files
export HADOOP_CONF_DIR="/etc/hadoop"
# Default classpath entries to append
#SPARK_CLASSPATH
# To include Hadoop's package jars
export SPARK_DIST_CLASSPATH="/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/contrib/capacity-scheduler/*.jar"

### Options read by executors and drivers running inside the cluster ###
# Storage directories to use on this node for shuffle and RDD data
export SPARK_LOCAL_DIRS="/pocket/spark/tmp"

### Generic options for the daemons used in the standalone deploy mode ###
# Alternate conf dir. (Default: ${SPARK_HOME}/conf)
export SPARK_CONF_DIR="/etc/spark"
# Where log files are stored.  (Default: ${SPARK_HOME}/logs)
export SPARK_LOG_DIR="/pocket/spark/log"
# Where the pid file is stored. (Default: /tmp)
#SPARK_PID_DIR       
# A string representing this instance of spark. (Default: $USER)
#SPARK_IDENT_STRING 
# The scheduling priority for daemons. (Default: 0)
#SPARK_NICENESS
# Run the proposed command in the foreground. It will not output a PID file.
#SPARK_NO_DAEMONIZE

# To set the IP address Spark binds to on this node
export SPARK_LOCAL_IP=${HOSTNAME}
# To set the public dns name of the driver program
#SPARK_PUBLIC_DNS

# To set the number of cores to use on this machine (Default: all available cores)
export SPARK_WORKER_CORES=4
# To set how much total memory workers have to give executors (e.g. 1000m, 2g)
# 1 Worker (you can say 1 machine or 1 Worker Node) can launch multiple Executors
export SPARK_WORKER_MEMORY=1g
# To use non-default ports for the worker
export SPARK_WORKER_WEBUI_PORT=8081
export SPARK_WORKER_PORT=8082
# To set the number of worker processes per node
export SPARK_WORKER_INSTANCES=1
# To set the working directory of worker processes
export SPARK_WORKER_DIR="/pocket/spark/tmp"
# To set config properties only for the worker (e.g. "-Dx=y")
export SPARK_WORKER_OPTS="${SPARK_WORKER_OPTS} -Djava.awt.headless=true -Dspark.ui.port=4040 -Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.driver.blockManager.port=7005 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
