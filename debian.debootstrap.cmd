#!/bin/bash -ex

PATH=${PATH}":/usr/sbin"
DEBOOTSTRAP='qemu-debootstrap'
name=${name:-bullseye}
variant=${variant:-minbase}
arch=${arch:-arm64}

command_validator() {
local _command=${1:-true}
command -v ${_command} || sudo apt-get install --yes --no-install-recommends ${_command}
}
command_validator ${DEBOOTSTRAP}

PROGNAME=${BASH_SOURCE[0]}
INCLUDE=${PROGNAME:0:-3}"inc"

[[ -f ${INCLUDE} ]] && . ${INCLUDE}

# Include a MACHINE file if exists
INCLUDE=$(dirname ${INCLUDE})/${MACHINE}/$(basename ${INCLUDE})
[[ -f ${INCLUDE} ]] && . ${INCLUDE}


rootfs=${rootfs:-${arch}-${name}-${variant}}

if [[ ! -e ${rootfs}/var/log/bootstrap.log ]];then
	sudo ${DEBOOTSTRAP} --arch=${arch} --variant=${variant} ${name} ${rootfs}
fi
