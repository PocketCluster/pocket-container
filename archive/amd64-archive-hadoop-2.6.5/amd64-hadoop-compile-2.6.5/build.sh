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
export PREFIX=pocketcluster

# - AMD64
# - ARMHF RPI2/3
# - ARM64 PINE64/ODROID-C2
export PLATFORM=amd64

# - dev     (unsquashed, in-develope)
# - release (squashed, in-production)
export DEV_TAG=dev
export RELEASE_TAG=latest

# please do this on very special occation where native lib compiling is needed. 
# 1) we need to support extra compression codecs. See NATIVELIB section
# 2) we need to packaging protobuf-2.5.0
# 3) armhf native compile failed

function build_hadoop_native_compile() {
	local HADOOP_VERSION=2.6.5
	local HADOOP_LIB_BUILD_TARGET=${PLATFORM}-hadoop-compile-${HADOOP_VERSION}
	local HADOOP_LIB_BUILD_PATH="./${HADOOP_LIB_BUILD_TARGET}/"
	local HADOOP_NATIVE_LIB_PATH=native
	if [ ! -d "./${HADOOP_NATIVE_LIB_PATH}" ]; then
		mkdir -p "./${HADOOP_NATIVE_LIB_PATH}"
	fi

	docker build --rm -t ${PREFIX}/${HADOOP_LIB_BUILD_TARGET}:${DEV_TAG} .
	docker run -v "${PWD}/${HADOOP_NATIVE_LIB_PATH}":/${HADOOP_NATIVE_LIB_PATH} ${PREFIX}/${HADOOP_LIB_BUILD_TARGET}:${DEV_TAG}
	pushd ${PWD}
	cd ${PWD}/${HADOOP_NATIVE_LIB_PATH}
	tar cvzf hadoop-native-lib-${HADOOP_VERSION}.tar.gz * 
	popd
	mv ${PWD}/${HADOOP_NATIVE_LIB_PATH}/hadoop-native-lib-${HADOOP_VERSION}.tar.gz ..
}

build_hadoop_native_compile