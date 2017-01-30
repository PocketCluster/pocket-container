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


function build_spark_slave() {
	local SPARK_BUILD_PATH=./armhf-spark-slave
	if [[ ! -f ${SPARK_BUILD_PATH}/spark-2.1.0-bin-without-hadoop.tgz ]]; then
	    echo "Apache Spark 2.6.5 not found"
	    wget "http://mirror.apache-kr.org/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz" -P ${SPARK_BUILD_PATH}/
	fi
	docker build --rm -t pocket/armhf-spark-slave:base ${SPARK_BUILD_PATH}/
	docker-squash -t pocket/armhf-spark-slave:2.1.0 pocket/armhf-spark-slave:base
	docker rmi pocket/armhf-spark-slave:base
}
README

:<<NATIVELIB
function build_hadoop_native_compile() {
	local HADOOP_VERSION=2.6.5
	local HADOOP_LIB_BUILD_TARGET=${PLATFORM}-hadoop-compile-${HADOOP_VERSION}
	local HADOOP_LIB_BUILD_PATH="./${HADOOP_LIB_BUILD_TARGET}/"
	local HADOOP_NATIVE_LIB_PATH=native
	if [ ! -d "${HADOOP_LIB_BUILD_PATH}${HADOOP_NATIVE_LIB_PATH}" ]; then
		mkdir -p "${HADOOP_LIB_BUILD_PATH}${HADOOP_NATIVE_LIB_PATH}"
	fi

	docker build --rm -t ${PREFIX}/${HADOOP_LIB_BUILD_TARGET}:${DEV_TAG} ${HADOOP_LIB_BUILD_PATH}
	docker run -v "${PWD}/${HADOOP_LIB_BUILD_TARGET}/${HADOOP_NATIVE_LIB_PATH}":/${HADOOP_NATIVE_LIB_PATH} ${PREFIX}/${HADOOP_LIB_BUILD_TARGET}:${DEV_TAG}
	pushd ${PWD}
	cd ${PWD}/${HADOOP_LIB_BUILD_TARGET}/${HADOOP_NATIVE_LIB_PATH}
	tar cvzf hadoop-native-lib-${HADOOP_VERSION}.tar.gz * 
	popd
	mv ${PWD}/${HADOOP_LIB_BUILD_TARGET}/${HADOOP_NATIVE_LIB_PATH}/hadoop-native-lib-${HADOOP_VERSION}.tar.gz ${PWD}/${PLATFORM}-hadoop-base-${HADOOP_VERSION}
}

# please do this on special occation where native lib compiling is needed. 
1) ATM, we need to support extra compression codecs. See NATIVELIB section
2) This fails where maven tries to build hadoop doc. Skip that part
#build_hadoop_native_compile
NATIVELIB


set -ex

#pocketcluster/<architecture>-<application>-<version>:<tag>
export PREFIX=pocketcluster

# - AMD64
# - ARMHF RPI2/3
# - ARM64 PINE64/ODROID-C2
export PLATFORM=armhf

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

## --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- ##

function build_baseimage() {
	local BASE_BUILD_TARGET="${PLATFORM}-baseimage"
	_build_squash ${BASE_BUILD_TARGET}
}

function build_zulu_jdk() {
	local JDK_VERSION=1.8.0
	local JDK_BUILD_TARGET=${PLATFORM}-zulu-jdk-${JDK_VERSION}
	_build_squash ${JDK_BUILD_TARGET}
}

function build_hadoop_base() {
	local SHOULD_SQUASH=${1}
	local HADOOP_VERSION=2.6.5
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-base-${HADOOP_VERSION}
	local HADOOP_BUILD_PATH=./${HADOOP_BUILD_TARGET}
	if [ ! -f "${HADOOP_BUILD_PATH}/id_rsa" ] || [ ! -f ${HADOOP_BUILD_PATH}/id_rsa.pub ]; then
	    echo "keyfile not found. please make copies from namenode"
		return
	fi
	if [[ ! -f ${HADOOP_BUILD_PATH}/hadoop-${HADOOP_VERSION}.tar.gz ]]; then
	    echo "Apache Hadoop ${HADOOP_VERSION} not found"
	    wget "http://mirror.apache-kr.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" -P ${HADOOP_BUILD_PATH}/
	fi
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		_build_squash ${HADOOP_BUILD_TARGET} || true
	else
		_unsquashed_build ${HADOOP_BUILD_TARGET} || true
	fi
}

function build_hadoop_datanode() {
	local SHOULD_SQUASH=${1}
	local HADOOP_VERSION=2.6.5
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-datanode-${HADOOP_VERSION}
	local HADOOP_BUILD_PATH=./${HADOOP_BUILD_TARGET}
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		sed 's/BUILDCHAINTAG/latest/g' ${HADOOP_BUILD_PATH}/Dockerfile.template > ${HADOOP_BUILD_PATH}/Dockerfile
		_build_squash ${HADOOP_BUILD_TARGET} || true
	else
		sed 's/BUILDCHAINTAG/dev/g' ${HADOOP_BUILD_PATH}/Dockerfile.template > ${HADOOP_BUILD_PATH}/Dockerfile
		_unsquashed_build ${HADOOP_BUILD_TARGET} || true
	fi
	rm ${HADOOP_BUILD_TARGET}/Dockerfile
}

function build_spark_slave() {
	local SHOULD_SQUASH=${1}
	local SPARK_VERSION=2.1.0
	local SPARK_BUILD_TARGET=${PLATFORM}-spark-slave-${SPARK_VERSION}
	local SPARK_BUILD_PATH=./${SPARK_BUILD_TARGET}
    if [[ ! -f ${SPARK_BUILD_PATH}/spark-2.1.0-bin-without-hadoop.tgz ]]; then
        echo "Apache Spark 2.6.5 not found"
        wget "http://mirror.apache-kr.org/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz" -P ${SPARK_BUILD_PATH}/
    fi
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		sed 's/BUILDCHAINTAG/latest/g' ${SPARK_BUILD_PATH}/Dockerfile.template > ${SPARK_BUILD_PATH}/Dockerfile
		_build_squash ${SPARK_BUILD_TARGET} || true
	else
		sed 's/BUILDCHAINTAG/dev/g' ${SPARK_BUILD_PATH}/Dockerfile.template > ${SPARK_BUILD_PATH}/Dockerfile
		_unsquashed_build ${SPARK_BUILD_TARGET} || true
	fi
	rm ${SPARK_BUILD_PATH}/Dockerfile
}


#build_baseimage
#build_zulu_jdk
#build_hadoop_base 0
#build_hadoop_datanode 0
build_spark_slave 0
