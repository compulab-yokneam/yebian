#!/bin/bash -ex

function compulab_install() {
    if [[ -n ${PACKAGES} ]];then
        apt-get update
        apt-get install --yes --no-install-recommends ${PACKAGES}
    fi
}

function compulab_force_install() {
    if [[ -n ${PACKAGES_FORCE} ]];then
    mkdir /tmp/install -p; cd /tmp/install
        apt-get update
        apt-get download ${PACKAGES_FORCE}
        for deb in *.deb;do
        dpkg -x ${deb} /
        done
    cd -
    rm -rf /tmp/install
    fi
}

function compulab_reinstall() {
    if [[ -n ${PACKAGES_REINSTALL} ]];then
        apt-get reinstall --yes ${PACKAGES_REINSTALL}
    fi
}

export FEATURES=${1:-"EMPTY:"}
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
PROGNAME=${BASH_SOURCE[0]}

INCLUDE=${PROGNAME:0:-3}"inc"
[[ -f ${INCLUDE} ]] && . ${INCLUDE}

# fnc file must be included after the inc
# this file uses the inc file definitions
INCLUDE=${PROGNAME:0:-3}"fnc"
[[ -f ${INCLUDE} ]] && . ${INCLUDE}

compulab_install
compulab_reinstall
compulab_force_install
