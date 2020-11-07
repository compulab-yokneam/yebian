#!/bin/bash -ex

function debian_install() {
    if [[ -n ${PACKAGES} ]];then
        apt-get update
        apt-get install --yes --no-install-recommends ${PACKAGES}
    fi
}

export DEBIAN_FRONTEND=noninteractive
PROGNAME=${BASH_SOURCE[0]}
INCLUDE=${PROGNAME:0:-3}"inc"

[[ -f ${INCLUDE} ]] && . ${INCLUDE}

debian_install
