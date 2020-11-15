#!/bin/bash -ex

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
    rootfs=${root_fs} source ${scripts}/debian.debootstrap.cmd
}

# Debian Extrat Install & Configuration
function stage_2_pre() {
DEBIAN_CONF=debian.config.inc
if [[ ! -e ${DIRNAME}/${DEBIAN_CONF} ]];then
cat << eof | tee -a ${DIRNAME}/${DEBIAN_CONF}
HOSTNAME=${MACHINE}
eof
fi
}

function stage_2() {
stage_2_pre
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

CONF=${DIRNAME}/compulab.install.inc
[[ -e ${CONF} ]] && . ${CONF} || ${EXIT} 3

yocto_httpserver

bind_mount

for cmd in 'compulab.repo-switch.cmd YOCTO' 'compulab.install.cmd' 'compulab.repo-switch.cmd DEBIAN';do
    sudo chroot ${root_fs} /tmp/${cmd}
done

bind_umount

_yocto_httpserver
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
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

INCLUDE=${PROGNAME:0:-3}"inc"
[[ -f ${INCLUDE} ]] && . ${INCLUDE}

DIRNAME=$(dirname ${PROGNAME})

# Read the Yocto conf file
# exit with an error if not exists
CONF=${DIRNAME}/../conf/local.conf
[[ -e ${CONF} ]] && . ${CONF} || ${EXIT} 2

# Init the Yocot BSP variables
# Requires for CompuLab Yocto packages
BUILDDIR=$(dirname $(dirname ${DEPLOY_DIR}))
BUILD_DIR=$(basename ${BUILDDIR})

# Init the script variables
scripts=${DIRNAME}
configs=${DIRNAME}/../conf
root_fs=${DIRNAME}/../rootfs
images=${DIRNAME}/../images

stages=${stages:-"1 2 3 4 5 6"}

trap bind_umount INT QUIT TERM

for s in ${stages};do
    ${copy_con}
    command -v stage_${s} &>/dev/null && stage_${s}
done
