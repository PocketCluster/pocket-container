#!/usr/bin/env bash
set -ex

#pocketcluster/<architecture>-<application>-<version>:<tag>
export PREFIX=${PREFIX:-"pc-master:5000"}

# - AMD64
# - ARMHF RPI2/3
# - ARM64 PINE64/ODROID-C2
export PLATFORM=${PLATFORM:-"x86_64"}

# temporary directory
export TMP_DIR=${TMP_DIR:-"/pocket"}

# - latest    (unsquashed, in-develope)
# - <ver num> (squashed, in-production)
export TAG=${TAG:-"latest"}
export REL_TAG="0.1.4"

function _build_squash() {
	local BUILD_TARGET=${1}
	local BUILD_PATH="./${1}/"
	docker build --no-cache --rm -t ${PREFIX}/${BUILD_TARGET}:${TAG} ${BUILD_PATH}
	TMPDIR=${TMP_DIR} docker-squash -t ${PREFIX}/${BUILD_TARGET}:${REL_TAG} ${PREFIX}/${BUILD_TARGET}:${TAG}
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

function build_hadoop_debug() {
	local SHOULD_SQUASH=${1}
	local BUILD_TARGET=${PLATFORM}-hadoop_debug
	local BUILD_PATH=./${BUILD_TARGET}
	if [ ${SHOULD_SQUASH} -eq 1 ]; then
		sed "s/BUILDCHAINTAG/${TAG}/g" ${BUILD_PATH}/Dockerfile.template > ${BUILD_PATH}/Dockerfile
		_build_squash ${BUILD_TARGET} || true
	else
		sed "s/BUILDCHAINTAG/${TAG}/g" ${BUILD_PATH}/Dockerfile.template > ${BUILD_PATH}/Dockerfile
		_unsquashed_build ${BUILD_TARGET} || true
	fi
	rm ${BUILD_PATH}/Dockerfile
}

#build_baseimage 0
build_hadoop_debug 0
