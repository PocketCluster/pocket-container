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
# We'll bind Spark to listen everything until it setup properly
#export SPARK_LOCAL_IP=${HOSTNAME}#export SPARK_LOCAL_IP=${HOSTNAME}
export SPARK_LOCAL_IP="0.0.0.0"
# To set the public dns name of the driver program
#SPARK_PUBLIC_DNS

### Options for the daemons used in the standalone deploy mode ###
# To bind the master to a different IP address or hostname
export SPARK_MASTER_HOST="pc-core"
# To use non-default ports for the master
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080
# To set config properties only for the master (e.g. "-Dx=y")
export SPARK_MASTER_OPTS="${SPARK_MASTER_OPTS} -Djava.awt.headless=true -Dspark.ui.port=4040 -Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.driver.blockManager.port=7005 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
# To allocate to the master, worker and history server themselves (default: 1g). 
# Same as -Xms1g -Xmx1g org.apache.spark.deploy.master.Master
export SPARK_DAEMON_MEMORY=1g
# To set config properties only for the history server (e.g. "-Dx=y")
#SPARK_HISTORY_OPTS
# To set config properties only for the external shuffle service (e.g. "-Dx=y")
#SPARK_SHUFFLE_OPTS
# To set config properties for all daemons (e.g. "-Dx=y")
#SPARK_DAEMON_JAVA_OPTS
# To set the public dns name of the master or workers
#SPARK_PUBLIC_DNS
