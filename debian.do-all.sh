#!/bin/bash -ex

PROGNAME=${BASH_SOURCE[0]}
DIRNAME=$(dirname ${PROGNAME})
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

CONF=${DIRNAME}/compulab.install.inc
[[ ! -e ${CONF} ]] && ${EXIT} 3
. ${CONF}

CONF=${DIRNAME}/../conf/local.conf
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

. ${DIRNAME}/debian.cmd
