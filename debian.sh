#!/bin/bash -ex

function bind_mount() {
    for d in dev sys proc; do
        mpoint=$(readlink -f ${root_fs}/${d})
        findmnt ${mpoint} &>/dev/null || sudo mount --bind /${d} ${root_fs}/${d}
    done
}

function bind_umount() {
    for d in dev sys proc; do
        mpoint=$(readlink -f ${root_fs}/${d})
        findmnt ${mpoint} &>/dev/null && sudo umount -l ${mpoint} || true
    done
}

# Copy Conf
function stage_ccopy() {
    if [[ -d ${root_fs} ]];then
        sudo cp -v ${scripts}/*.cmd ${scripts}/*.inc ${root_fs}/tmp
        sudo cp -v ${configs}/yocto.list ${root_fs}/etc/apt/sources.list.d/
        copy_con='true'
    fi
}
copy_con='stage_ccopy'

# Debian Debootstrap
function stage_1() {
if [[ ! -e ${root_fs}/var/log/bootstrap.log ]];then
    rootfs=${root_fs} name=${name} ${scripts}/debian.debootstrap.cmd
fi
}

# Debian Extrat Install & Configuration
function stage_2() {
bind_mount

for cmd in 'debian.install.cmd' 'debian.config.cmd';do
    sudo chroot ${root_fs} /tmp/${cmd}
done

bind_umount
}

# Debian Docker Install
function stage_3() {
bind_mount

for cmd in 'docker.install.cmd';do
    sudo chroot ${root_fs} /tmp/${cmd}
done

bind_umount
}

# Debian CompuLab Install
function stage_4() {

command -v yocto_httpserver &>/dev/null && yocto_httpserver || return

bind_mount

for cmd in 'compulab.repo-switch.cmd YOCTO' 'compulab.install.cmd' 'compulab.repo-switch.cmd DEBIAN';do
    sudo chroot ${root_fs} /tmp/${cmd}
done

bind_umount
}

# Image Build
function stage_5() {
mkdir -p ${images}
local IMAGE=${images}/compulab-debian-${name}-$(date +%Y%m%d%H%M%S).sdcard.img
dd if=/dev/zero of=${IMAGE} bs=1M count=2048
local DEVICE=$(sudo losetup --show --find ${IMAGE})
local cmd=image.cmd

IMX_BOOT="/boot/"$(basename $(ls ${root_fs}/boot/imx*))
cat << eof | sudo tee ${root_fs}/tmp/${cmd}
#!/bin/bash -x

rm -rf /tmp/*.cmd /tmp/*.inc /var/cache/apt /etc/apt/sources.list.d/yocto*
SRC=/ DST=${DEVICE} QUIET=Yes cl-deploy.work
dd if=${IMX_BOOT} of=${DEVICE} bs=1K seek=${IMX_BOOT_SEEK}

eof
bind_mount
    sudo sed -i 's/\(local _start=\).*/\14/'  ${root_fs}/usr/local/bin/cl-deploy.work
    sudo chmod a+x ${root_fs}/tmp/${cmd}
    sudo chroot ${root_fs} /tmp/${cmd}
bind_umount
    sudo losetup -d ${DEVICE}
cat << eof
Image file name:
$(readlink -f ${IMAGE})
eof
}

# Final Stage -- report only
function stage_6() {
cat << eof
Stages [ ${stages} ] completed
eof
}

PROGNAME=${BASH_SOURCE[0]}
DIRNAME=$(dirname ${PROGNAME})
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

scripts=${DIRNAME}
configs=${DIRNAME}/../conf
root_fs=${DIRNAME}/../rootfs
images=${DIRNAME}/../images
name=bullseye

stages=${stages:-"1 2 3 4 5 6"}

trap bind_umount INT QUIT TERM

for s in ${stages};do
    ${copy_con}
    command -v stage_${s} &>/dev/null && stage_${s}
done
