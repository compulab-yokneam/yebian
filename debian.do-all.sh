#!/bin/bash -x

PROGNAME=${BASH_SOURCE[0]}
DIRNAME=$(dirname ${PROGNAME})
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

CONF=${DIRNAME}/compulab.inc
[[ ! -e ${CONF} ]] && ${EXIT} 3
. ${CONF}

CONF=${DIRNAME}/../local/local.conf
[[ ! -e ${CONF} ]] && ${EXIT} 2
. ${CONF}

BUILD=${DIRNAME}/../build

BUILDDIR=$(dirname $(dirname ${DEPLOY_DIR})) 
BUILD_DIR=$(basename ${BUILDDIR})

pushd .

cd ${BUILDDIR}/../

source setup-environment ${BUILD_DIR}
bitbake ${PACKAGES} package-index
cd tmp/deploy/deb
python -m SimpleHTTPServer 5678 &
PID=$!

popd

mkdir -p ${BUILD}

${DIRNAME}/debian.sh

kill -9 ${PID}
