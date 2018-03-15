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
export PREFIX=pc-master:5000

# - x86_64  PC-CORE
# - armhf   RPI2/3
# - aarch64 PINE64/ODROID-C2
export PLATFORM=aarch64

# temporary directory
export TMP_DIR=${TMP_DIR:-"/work/TEMP"}

# - latest    (unsquashed, in-develope)
# - <ver num> (squashed, in-production)
export TAG=${TAG:-"latest"}
export REL_TAG="0.1.4"

function _build_squash() {
	local BUILD_TARGET=${1}
	local BUILD_PATH="./${1}/"
	docker build --no-cache --rm -t ${PREFIX}/${BUILD_TARGET}:${TAG} ${BUILD_PATH}
	TMPDIR=${TMP_DIR} docker-squash -t ${PREFIX}/${BUILD_TARGET}:${TAG} ${PREFIX}/${BUILD_TARGET}:${TAG}
}

function _unsquashed_build() {
	local BUILD_TARGET=${1}
	local BUILD_PATH=./${1}/
	docker build --rm -t ${PREFIX}/${BUILD_TARGET}:${TAG} ${BUILD_PATH}
}

## --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- ##

function build_baseimage() {
	local BASE_BUILD_TARGET="${PLATFORM}-baseimage"
	local SHOULD_SQUASH=${1}
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		_build_squash ${BASE_BUILD_TARGET} || true
	else
		_unsquashed_build ${BASE_BUILD_TARGET} || true
	fi
}

function build_openjdk() {
	local SHOULD_SQUASH=${1}
	local JDK_VERSION=1.8.0
	local JDK_BUILD_TARGET=${PLATFORM}-openjdk-${JDK_VERSION}
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		_build_squash ${JDK_BUILD_TARGET} || true
	else
		_unsquashed_build ${JDK_BUILD_TARGET} || true
	fi
}

function build_hadoop_base() {
	local SHOULD_SQUASH=${1}
	local HADOOP_VERSION=2.7.3
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
	local HADOOP_VERSION=2.7.3
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-datanode-${HADOOP_VERSION}
	local HADOOP_BUILD_PATH=./${HADOOP_BUILD_TARGET}
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		sed "s/BUILDCHAINTAG/${TAG}/g" ${HADOOP_BUILD_PATH}/Dockerfile.template > ${HADOOP_BUILD_PATH}/Dockerfile
		_build_squash ${HADOOP_BUILD_TARGET} || true
	else
		sed "s/BUILDCHAINTAG/${TAG}/g" ${HADOOP_BUILD_PATH}/Dockerfile.template > ${HADOOP_BUILD_PATH}/Dockerfile
		_unsquashed_build ${HADOOP_BUILD_TARGET} || true
	fi
	rm ${HADOOP_BUILD_TARGET}/Dockerfile
}

function build_spark_slave() {
	local SHOULD_SQUASH=${1}
	local SPARK_VERSION=2.1.0
	local SPARK_BUILD_TARGET=${PLATFORM}-spark-slave-${SPARK_VERSION}
	local SPARK_BUILD_PATH=./${SPARK_BUILD_TARGET}
    if [[ ! -f ${SPARK_BUILD_PATH}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz ]]; then
        echo "Apache Spark ${SPARK_VERSION} not found"
        wget "http://mirror.apache-kr.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz" -P ${SPARK_BUILD_PATH}/
    fi
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		sed "s/BUILDCHAINTAG/${TAG}/g" ${SPARK_BUILD_PATH}/Dockerfile.template > ${SPARK_BUILD_PATH}/Dockerfile
		_build_squash ${SPARK_BUILD_TARGET} || true
	else
		sed "s/BUILDCHAINTAG/${TAG}/g" ${SPARK_BUILD_PATH}/Dockerfile.template > ${SPARK_BUILD_PATH}/Dockerfile
		_unsquashed_build ${SPARK_BUILD_TARGET} || true
	fi
	rm ${SPARK_BUILD_PATH}/Dockerfile
}

function build_jupyter_node() {
	local SHOULD_SQUASH=${1}
	local JUPYTER_VERSION=4.2.1
	local JUPYTER_BUILD_TARGET=${PLATFORM}-jupyter-node-${JUPYTER_VERSION}
	local JUPYTER_BUILD_PATH=./${JUPYTER_BUILD_TARGET}
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		sed "s/BUILDCHAINTAG/${TAG}/g" ${JUPYTER_BUILD_PATH}/Dockerfile.template > ${JUPYTER_BUILD_PATH}/Dockerfile
		_build_squash ${JUPYTER_BUILD_TARGET} || true
	else
		sed "s/BUILDCHAINTAG/${TAG}/g" ${JUPYTER_BUILD_PATH}/Dockerfile.template > ${JUPYTER_BUILD_PATH}/Dockerfile
		_unsquashed_build ${JUPYTER_BUILD_TARGET} || true
	fi
	rm ${JUPYTER_BUILD_PATH}/Dockerfile
}

function squash_final_node() {
	local JUPYTER_VERSION=4.2.1
	local BUILD_TARGET=${PLATFORM}-jupyter-node-${JUPYTER_VERSION}
	TMPDIR=${TMP_DIR} docker-squash -t ${PREFIX}/${BUILD_TARGET}:${REL_TAG} ${PREFIX}/${BUILD_TARGET}:${TAG}
}

#build_baseimage 0
#build_openjdk 0
#build_hadoop_base 0
#build_hadoop_datanode 0
#build_spark_slave 0
build_jupyter_node 0
squash_final_node