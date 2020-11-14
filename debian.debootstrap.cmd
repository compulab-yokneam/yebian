#!/bin/bash -ex

DEBOOTSTRAP='qemu-debootstrap'

command_validator() {
local _command=${1:-true}
command -v ${_command} || sudo apt-get install --yes --no-install-recommends ${_command}
}

name=${name:-bullseye}
variant=${variant:-minbase}
arch=${arch:-arm64}

command_validator ${DEBOOTSTRAP}

PROGNAME=${BASH_SOURCE[0]}
INCLUDE=${PROGNAME:0:-3}"inc"

[[ -f ${INCLUDE} ]] && . ${INCLUDE}

rootfs=${rootfs:-${arch}-${name}-${variant}}

sudo ${DEBOOTSTRAP} --arch=${arch} --variant=${variant} ${name} ${rootfs}
