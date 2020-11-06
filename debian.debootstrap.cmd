#!/bin/bash -ex

DEBOOTSTRAP='qemu-debootstrap'

command_validator() {
local _command=${1:-true}
command -v ${_command} || sudo apt-get install --yes --no-install-recommends ${_command}
}

name=${name:-bullseye}
variant=${variant:-minbase}
arch=${arch:-arm64}
rootfs=${rootfs:-${arch}-${name}-${variant}}

command_validator ${DEBOOTSTRAP}

sudo ${DEBOOTSTRAP} --arch=${arch} --variant=${variant} ${name} ${rootfs}
