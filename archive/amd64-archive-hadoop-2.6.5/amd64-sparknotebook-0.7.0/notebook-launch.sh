#!/usr/bin/env bash

source /root/.bashrc

export EXTRA_CLASSPATH=/opt/hadoop/share/hadoop/common/lib/hadoop-lzo.jar
export SPARK_NOTEBOOK_PORT=9001

/opt/bin/spark-notebook -Dconfig.file=/opt/conf/application.conf -Dhttp.port=${SPARK_NOTEBOOK_PORT}