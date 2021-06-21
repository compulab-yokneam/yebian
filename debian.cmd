#!/bin/bash -e

# Copy Conf
function stage_ccopy() {
    if [[ -d ${root_fs} ]];then
        sudo cp ${scripts}/*.{cmd,inc,fnc} ${root_fs}/tmp
	if [[ -d ${scripts}/${MACHINE} ]];then
            sudo cp ${scripts}/${MACHINE}/* ${root_fs}/tmp
        fi
        copy_con='true'
    fi
}
copy_con='stage_ccopy'

function stage_cgen() {
    DEBOOTSTRAP_CONF=${DIRNAME}/${MACHINE}/debian.debootstrap.inc
    if [[ ! -e ${DEBOOTSTRAP_CONF} ]];then
        CFG=${DEBOOTSTRAP_CONF} source ${scripts}/debian.debootstrap.cfg
cat << eof
        Review the created configuration;
        Re-run the main script.
eof
    exit 0
    fi
}

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

SOURCE_LIST=sources.list
if [[ -e ${DIRNAME}/distro/${name}/${SOURCE_LIST} ]];then
sudo cp ${DIRNAME}/distro/${name}/${SOURCE_LIST} ${root_fs}/etc/apt/
sudo chown root:root ${root_fs}/etc/apt/${SOURCE_LIST}
fi
}

function stage_2() {
stage_2_pre
bind_mount

for cmd in 'compulab.repo-switch.cmd DEBIAN' 'debian.install.cmd' 'debian.config.cmd';do
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
function stage_4_pre() {
yocto_packages
yocto_deb_init
# Copy the yocto.list every time the server was started
# The server uses different HTTPORT each start
sudo cp ${configs}/yocto.list ${root_fs}/etc/apt/sources.list.d/
[[ -n ${socarch} ]] && sudo chroot ${root_fs} dpkg --add-architecture ${socarch} || true
}

function stage_4_post() {
    yocto_deb_fini
}

function stage_4() {

stage_4_pre

bind_mount

for cmd in 'compulab.repo-switch.cmd YOCTO' 'compulab.install.cmd' 'compulab.repo-switch.cmd DEBIAN';do
    sudo chroot ${root_fs} /tmp/${cmd} ${FEATURES}
done

bind_umount

stage_4_post

}

# Image Pre-Build
function stage_5_pre() {
if [[ ! -f ${cl_deploy_layout} ]];then
cat << eof
	File ${cl_deploy_layout} is not found
	please update cl-deploy package
eof
exit 3
fi

[[ -z ${IMX_BOOT_PATT} ]] && ${EXIT} 4
stat ${root_fs}/boot/${IMX_BOOT_PATT} &>/dev/null || ${EXIT} 5
# Offline run clean up
[[ -d ${root_fs}/run ]] && sudo rm -rf ${root_fs}/run/* || true
}

# Rootfs size calculation

function wait_for_noio() {
    local __block=$(basename ${1})
    local __time=${2}
    local __io=();
    __io[0]=$(awk '$0=$1' /sys/class/block/${__block}/stat)
    for i in $(seq 1 ${__time});do
    sleep 1
    __io[${i}]=$(awk '$0=$1' /sys/class/block/${__block}/stat)
    if [[ ${__io[i-1]} -eq ${__io[i]} ]];then
        break;
    fi
    done
}

# Image Build
function stage_5() {
stage_5_pre

arch=$(sudo chroot ${root_fs} dpkg --print-architecture)

mkdir -p ${images}
local LNAME="${images}/$(basename ${root_fs})"
local RNAME=sdcard.img
local IMAGE=${LNAME}-$(date +%Y%m%d%H%M%S).${RNAME}
local LIMAGE=${LNAME}.${RNAME}
image_file=${IMAGE} root_cnt=${root_cnt} root_fs=${root_fs} source ${cl_deploy_layout}

local DEVICE=$(sudo losetup --show --find --partscan ${IMAGE})
local cmd=image.cmd

IMX_BOOT="/boot/"$(basename $(ls ${root_fs}/boot/${IMX_BOOT_PATT}))
cat << eof | sudo tee ${root_fs}/tmp/${cmd}
#!/bin/bash -x

rm -rf /tmp/*.cmd /tmp/*.inc /var/cache/apt /etc/apt/sources.list.d/yocto*
chmod 0755 /
SRC=/ DST=${DEVICE} ROOT_CNT=${root_cnt} QUIET=Yes PARTED=Yes cl-deploy.work
sync;sync;sync
dd if=${IMX_BOOT} of=${DEVICE} bs=1K seek=${IMX_BOOT_SEEK}

eof

bind_mount
    sudo sed -i 's/\(local _start=\).*/\14/'  ${root_fs}/usr/local/bin/cl-deploy.work
    sudo chmod a+x ${root_fs}/tmp/${cmd}
    sudo chroot ${root_fs} /tmp/${cmd}
# sync before unmount
sync;sync;sync
# wait for ios to complete in 60sec
wait_for_noio ${DEVICE} 60
wait_for_noio ${DEVICE} 5

bind_umount

sudo losetup -d ${DEVICE}

ln -sf $(basename ${IMAGE}) ${LIMAGE}

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

function stage_init() {
bind_umount
yocto_deb_fini
}

function stage_http() {
yocto_deb_init
}

PROGNAME=${BASH_SOURCE[0]}
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

if [[ -z ${BUILDDIR} ]];then
cat << eof
Running outside of the Yocto Buid Environment
Exiting ...
eof
exit 1
fi

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
run=${DIRNAME}/../run
configs=${DIRNAME}/../conf
rootfs=${DIRNAME}/../rootfs
images=${DIRNAME}/../images

mkdir -p ${run} ${images} ${rootfs}

# Gloabal Variables

INCLUDE=${PROGNAME:0:-3}"include"
[[ -f ${INCLUDE} ]] && . ${INCLUDE}

for i in ${scripts}/*.inc ;do
	source ${i}
done

if [ -d ${scripts}/${MACHINE} ];then
    for i in ${scripts}/${MACHINE}/* ;do
        source ${i}
    done
fi

source ${scripts}/compulab.install.fnc

stage_cgen

root_fs=${root_fs:-${DIRNAME}/../rootfs/${distro}-${name}-${arch}-${variant}}
# cl-deploy provides image size:layout:create methods
# the lates cl-deploy must be used
cl_deploy_layout=${root_fs}/usr/local/bin/cl-deploy.layout

root_cnt=${root_cnt:-1}

stages=${stages:-"1 2 3 4 5 6"}

trap stage_init INT QUIT TERM

stage_init

set -x
for s in ${stages};do
    ${copy_con}
    command -v stage_${s} &>/dev/null && stage_${s}
done
set +x
