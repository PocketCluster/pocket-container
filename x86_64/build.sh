#!/usr/bin/env bash
:<<README
--- x --- x --- x --- x --- x --- x --- x --- x --- HADOOP 2.6.5 --- x --- x --- x --- x --- x --- x --- x --- x --- x ---

- /pocket/<application>/<version> <---> /pocket
- [CONT] Let /pocket be the top directory to write
- [HOST] Let /pocket/<application>/<version>/ be the top directory to store

[HOST] /pocket/hadoop/2.6.5/
[CONT]       /pocket/hadoop/

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
	/pocket/hadoop/hdfs/namenode
	/pocket/hadoop/hdfs/namenode2-checkpoint
	/pocket/hadoop/hdfs/yarn/nm-local-dir
	/pocket/hadoop/hdfs/yarn/nm-log-dir/userlogs

	# log file path
	/pocket/hadoop/log

2. [CONT] copy /opt/hadoop/etc/hadood to /etc/hadoop
3. [CONT] mount hadoop log directory created at host so log can be permanant (should it be?)
	export HADOOP_LOG_DIR="/pocket/hadoop/log"

4. [CONT] Check if headless option is required
	export JAVA_TOOL_OPTIONS='-Djava.awt.headless=true'

5. [CONT] HADOOP_HOME="/opt/hadoop"

--- x --- x --- x --- x --- x --- x --- x --- x --- SPARK 2.1.0 --- x --- x --- x --- x --- x --- x --- x --- x --- x ---

[HOST] /pocket/spark/2.1.0/
[CONT]       /pocket/spark/

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

:<<NATIVELIB
Picked up JAVA_TOOL_OPTIONS: -Djava.awt.headless=true
17/01/28 16:39:55 WARN bzip2.Bzip2Factory: Failed to load/initialize native-bzip2 library system-native, will use pure-Java version
17/01/28 16:39:55 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
Native library checking:
hadoop:  true /opt/hadoop/lib/native/libhadoop.so.1.0.0
zlib:    true /lib/x86_64-linux-gnu/libz.so.1
snappy:  false
lz4:     true revision:99
bzip2:   false
openssl: true /usr/lib/x86_64-linux-gnu/libcrypto.so
17/01/28 16:39:55 INFO util.ExitUtil: Exiting with status 1

## --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- ##
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

function build_hadoop_native_base() {
	local HADOOP_VERSION=2.6.5
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-base-native-${HADOOP_VERSION}
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
# please do this on very special occation where native lib compiling is needed. 
# 1) we need to support extra compression codecs. See NATIVELIB section
# 2) we need to packaging protobuf-2.5.0
# 3) armhf native compile failed

#build_hadoop_native_compile
#build_hadoop_native_base
## --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- x --- ##
NATIVELIB

set -ex

#pocketcluster/<architecture>-<application>-<version>:<tag>
export PREFIX=${PREFIX:-"pc-master:5000"}

# - AMD64
# - ARMHF RPI2/3
# - ARM64 PINE64/ODROID-C2
export PLATFORM=${PLATFORM:-"x86_64"}

# - dev     (unsquashed, in-develope)
# - release (squashed, in-production)
export TAG=${TAG:-latest}
export TMP_DIR=${TMP_DIR:-"/pocket"}

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
	    echo "keyfile not found. let's generate one"
		ssh-keygen -t rsa -C "stkim1@pocketcluster.io" -f ${HADOOP_BUILD_PATH}/id_rsa -P ''	    
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

function build_hadoop_namenode() {
	local SHOULD_SQUASH=${1}
	local HADOOP_VERSION=2.7.3
	local HADOOP_BUILD_TARGET=${PLATFORM}-hadoop-namenode-${HADOOP_VERSION}
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

function build_spark_driver() { 
	local SHOULD_SQUASH=${1}
	local SPARK_VERSION=2.1.0
	local SPARK_BUILD_TARGET=${PLATFORM}-spark-driver-${SPARK_VERSION}
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

function build_jupyter_master() {
	local SHOULD_SQUASH=${1}
	local JUPYTER_VERSION=4.2.1
	local JUPYTER_BUILD_TARGET=${PLATFORM}-jupyter-master-${JUPYTER_VERSION}
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

#build_baseimage 0
#build_openjdk 0
#build_hadoop_base 0 
#build_hadoop_namenode 0
#build_spark_driver 0
build_jupyter_master 0
