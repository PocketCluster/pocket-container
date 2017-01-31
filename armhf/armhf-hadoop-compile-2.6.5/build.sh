#!/usr/bin/env bash

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

# please do this on very special occation where native lib compiling is needed. 
# 1) we need to support extra compression codecs. See NATIVELIB section
# 2) we need to packaging protobuf-2.5.0
# 3) armhf native compile failed

function build_hadoop_native_compile() {
	local HADOOP_VERSION=2.6.5
	local HADOOP_LIB_BUILD_TARGET=${PLATFORM}-hadoop-compile-${HADOOP_VERSION}
	local HADOOP_NATIVE_LIB_PATH="hadoop-native"
	local PROTOBUF_NATIVE_LIB_PATH="protobuf-native"
	if [ ! -d "./${HADOOP_NATIVE_LIB_PATH}" ]; then
		mkdir -p "./${HADOOP_NATIVE_LIB_PATH}"
	fi
	if [ ! -d "./${PROTOBUF_NATIVE_LIB_PATH}" ]; then
		mkdir -p "./${PROTOBUF_NATIVE_LIB_PATH}"
	fi

	docker build --rm -t ${PREFIX}/${HADOOP_LIB_BUILD_TARGET}:${DEV_TAG} .
	docker run -v "${PWD}/${HADOOP_NATIVE_LIB_PATH}:/${HADOOP_NATIVE_LIB_PATH}" -v "${PWD}/${PROTOBUF_NATIVE_LIB_PATH}:/${PROTOBUF_NATIVE_LIB_PATH}" ${PREFIX}/${HADOOP_LIB_BUILD_TARGET}:${DEV_TAG}
:<<ARCHIVING_SKIPPED
	pushd ${PWD}
	cd "${PWD}/${HADOOP_NATIVE_LIB_PATH}"
	tar cvzf hadoop-native-lib-${HADOOP_VERSION}.tar.gz * 
	popd
	mv "${PWD}/${HADOOP_NATIVE_LIB_PATH}/hadoop-native-lib-${HADOOP_VERSION}.tar.gz" ..
ARCHIVING_SKIPPED
}

build_hadoop_native_compile