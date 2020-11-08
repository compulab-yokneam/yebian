#!/bin/bash -ex

PROGNAME=${BASH_SOURCE[0]}
DIRNAME=$(dirname ${PROGNAME})
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

function yocto_httpserver() {

	pushd .

	cd ${BUILDDIR}/../

	source setup-environment ${BUILD_DIR}
	bitbake ${PACKAGES} package-index
	cd tmp/deploy/deb
	python -m SimpleHTTPServer 5678 &
	export PID=$!

	popd

}

CONF=${DIRNAME}/compulab.inc
[[ ! -e ${CONF} ]] && ${EXIT} 3
. ${CONF}

CONF=${DIRNAME}/../local/local.conf
[[ ! -e ${CONF} ]] && ${EXIT} 2
. ${CONF}

DEBIAN_CONF=debian.config.inc
if [[ ! -e ${DIRNAME}/${DEBIAN_CONF} ]];then
cat << eof | tee -a ${DIRNAME}/${DEBIAN_CONF}
HOSTNAME=${MACHINE}
eof
fi

BUILDDIR=$(dirname $(dirname ${DEPLOY_DIR})) 
BUILD_DIR=$(basename ${BUILDDIR})

. ${DIRNAME}/debian.sh

[[ -n ${PID} ]] && kill -9 ${PID}
