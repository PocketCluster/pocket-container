#!/usr/bin/env bash
:<<README
--- x --- x --- x --- x --- x --- x --- x --- x --- HADOOP 2.6.5 --- x --- x --- x --- x --- x --- x --- x --- x --- x ---

- /pocket/<application>/<version> <---> /pocket
- [CONT] Let /pocket be the top directory to write
- [HOST] Let /pocket/<application>/<version>/ be the top directory to store

[HOST] /pocket/hadoop/2.6.5/
[CONT]              /pocket/

- [HOST] PATH
	# namenode path
	mkdir -p /pocket/hadoop/2.6.5/hdfs/namenode
	mkdir -p /pocket/hadoop/2.6.5/hdfs/namenode2-checkpoint
	mkdir -p /pocket/hadoop/2.6.5/hdfs/datanode
	mkdir -p /pocket/hadoop/2.6.5/hdfs/yarn/nm-local-dir
	mkdir -p /pocket/hadoop/2.6.5/hdfs/yarn/nm-log-dir/userlogs

	# log file path
	mkdir -p /pocket/hadoop/2.6.5/log

	#change log
	chown -R <user>:<user> /pocket/

- [CONT]
	# config path
	/etc/hadoop

	# namenode path
	/pocket/hdfs/namenode
	/pocket/hdfs/namenode2-checkpoint
	/pocket/hdfs/datanode
	/pocket/hdfs/yarn/nm-local-dir
	/pocket/hdfs/yarn/nm-log-dir/userlogs

	# log file path
	/pocket/log



2. [CONT] copy /opt/hadoop/etc/hadood to /etc/hadoop
3. [CONT] mount hadoop log directory created at host so log can be permanant (should it be?)
	export HADOOP_LOG_DIR="/pocket/log"

4. [CONT] Check if headless option is required
	export JAVA_TOOL_OPTIONS='-Djava.awt.headless=true'

5. [CONT] HADOOP_HOME="/opt/hadoop"

--- x --- x --- x --- x --- x --- x --- x --- x --- SPARK 2.1.0 --- x --- x --- x --- x --- x --- x --- x --- x --- x ---

[HOST] /pocket/spark/2.1.0/
[CONT]              /pocket/

- [HOST] PATH
	# log file path
	mkdir -p /pocket/spark/2.1.0/log

	# intermediate dir path
	mkdir -p /pocket/spark/2.1.0/work
	mkdir -p /pocket/spark/2.1.0/metastore_db

	chmod 777 /pocket/spark/2.1.0/
	chown -R pocket:pocket /pocket/

- [CONT]
	# config path
	/etc/spark

	# log file path
	/pocket/log

	# intermediate dir path
	/pocket/work
	/pocket/metastore_db

README

:<<SPARK
function build_spark_driver() {
	local SPARK_BUILD_PATH=./amd64-spark-driver
	if [[ ! -f ${SPARK_BUILD_PATH}/spark-2.1.0-bin-without-hadoop.tgz ]]; then
	    echo "Apache Spark 2.6.5 not found"
	    wget "http://mirror.apache-kr.org/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz" -P ${SPARK_BUILD_PATH}/
	fi
	docker build --rm -t pocketcluster/amd64-spark-slave:dev ${SPARK_BUILD_PATH}/
	docker-squash -t pocketcluster/amd64-spark-slave:2.1.0 pocketcluster/amd64-spark-slave:dev
	docker rmi pocketcluster/amd64-spark-slave:dev
}
SPARK

set -ex

#pocketcluster/<architecture>-<application>-<version>:<tag>
export PREFIX=pocketcluster

# - AMD64
# - ARMHF RPI2/3
# - ARM64 PINE64/ODROID-C2
export PLATFORM=amd64

# - dev     (unsquashed, in-develope)
# - release (squashed, in-production)
export DEV_TAG=dev
export RELEASE_TAG=latest

function _build_squash() {
	local BUILD_TARGET=${1}
	local BUILD_PATH="./${1}/"
	docker build --no-cache --rm -t ${PREFIX}/${BUILD_TARGET}:${DEV_TAG} ${BUILD_PATH}
	docker-squash -t ${PREFIX}/${BUILD_TARGET}:${RELEASE_TAG} ${PREFIX}/${BUILD_TARGET}:${DEV_TAG}
	docker rmi ${PREFIX}/${BUILD_TARGET}:${DEV_TAG}
}

function _unsquashed_build() {
	local BUILD_TARGET=${1}
	local BUILD_PATH=./${1}/
	docker build --rm -t ${PREFIX}/${BUILD_TARGET}:${DEV_TAG} ${BUILD_PATH}
}

function build_baseimage() {
	local BASE_BUILD_TARGET="${PLATFORM}-baseimage"
	_build_squash ${BASE_BUILD_TARGET}
}

function build_openjdk() {
	local JDK_VERSION=1.8.0
	local JDK_BUILD_TARGET=${PLATFORM}-openjdk-${JDK_VERSION}
	_build_squash ${JDK_BUILD_TARGET}
}

function build_hadoop_base() {
	local HADOOP_VERSION=2.6.5
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-base-${HADOOP_VERSION}
	local HADOOP_BUILD_PATH=./${HADOOP_BUILD_TARGET}
	if [ ! -f "${HADOOP_BUILD_PATH}/id_rsa" ] || [ ! -f ${HADOOP_BUILD_PATH}/id_rsa.pub ]; then
	    echo "keyfile not found. let's generate one"
		ssh-keygen -t rsa -C "stkim1@pocketcluster.io" -f ${HADOOP_BUILD_PATH}/id_rsa -P ''	    
	fi
	if [[ ! -f ${HADOOP_BUILD_PATH}/hadoop-${HADOOP_VERSION}.tar.gz ]]; then
	    echo "Apache Hadoop ${HADOOP_VERSION} not found"
	    wget "http://mirror.apache-kr.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" -P ${HADOOP_BUILD_PATH}/
	fi
	_build_squash ${HADOOP_BUILD_TARGET}
}

function build_hadoop_namenode() {
	local HADOOP_VERSION=2.6.5
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-namenode-${HADOOP_VERSION}
	_unsquashed_build ${HADOOP_BUILD_TARGET}
}

#build_baseimage
#build_openjdk
#build_hadoop_base
build_hadoop_namenode