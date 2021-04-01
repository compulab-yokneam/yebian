#!/bin/bash -ex

# Copy Conf
function stage_ccopy() {
    if [[ -d ${root_fs} ]];then
        sudo cp -v ${scripts}/*.cmd ${scripts}/*.inc ${root_fs}/tmp
	# Moved to stage_4_pre
        # sudo cp -v ${configs}/yocto.list ${root_fs}/etc/apt/sources.list.d/
	if [[ -d ${scripts}/${MACHINE} ]];then
            sudo cp -v ${scripts}/${MACHINE}/* ${root_fs}/tmp
        fi
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

SOURCE_LIST=sources.list
if [[ -e ${DIRNAME}/distro/${name}/${SOURCE_LIST} ]];then
sudo cp -v ${DIRNAME}/distro/${name}/${SOURCE_LIST} ${root_fs}/etc/apt/
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
ls -tr ${DEPLOY_DIR}/deb | awk '($0="#deb [trusted=yes] http://localhost:HTTPPORT/"$0" /")' > ${configs}/yocto.list
sed "s/HTTPPORT/${HTTPPORT}/g" -i ${configs}/yocto.list
sudo cp -v ${configs}/yocto.list ${root_fs}/etc/apt/sources.list.d/
[[ -n ${socarch} ]] && sudo chroot ${root_fs} dpkg --add-architecture ${socarch} || true
}

function stage_4() {
export HTTPPORT=$(($(($(($(dd if=/dev/urandom count=1 bs=8 2>/dev/null | xxd -a | awk '($0="0x"$2)')))%4096))+4096))
stage_4_pre
yocto_httpserver

bind_mount

for cmd in 'compulab.repo-switch.cmd YOCTO' 'compulab.install.cmd' 'compulab.repo-switch.cmd DEBIAN';do
    sudo chroot ${root_fs} /tmp/${cmd}
done

bind_umount

_yocto_httpserver
}

# Image Pre-Build
function stage_5_pre() {
[[ -z ${IMX_BOOT_PATT} ]] && ${EXIT} 4
stat ${root_fs}/boot/${IMX_BOOT_PATT}* &>/dev/null || ${EXIT} 5
# Offline run clean up
[[ -d ${root_fs}/run ]] && sudo rm -rf ${root_fs}/run/* || true
}

# Rootfs size calculation
function calc_image_size() {
    local __resultval=${1}
    local __rootfs=$(readlink -f ${root_fs})
    local __size=$(sudo du -sk ${__rootfs} | awk '$0=$1')
    __size=$(($(($(($((${__size}>>10))+1536))>>10))<<10))
    eval ${__resultval}=${__size}
}

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
calc_image_size image_size

arch=$(sudo chroot ${root_fs} dpkg --print-architecture)
dist=${distro[${name}]}

mkdir -p ${images}
local LNAME="${images}/compulab-${dist}-${name}-${arch}"
local RNAME=sdcard.img
local IMAGE=${LNAME}-$(date +%Y%m%d%H%M%S).${RNAME}
local LIMAGE=${LNAME}.${RNAME}
dd if=/dev/zero of=${IMAGE} bs=1M count=${image_size}
local DEVICE=$(sudo losetup --show --find ${IMAGE})
local cmd=image.cmd

IMX_BOOT="/boot/"$(basename $(ls ${root_fs}/boot/${IMX_BOOT_PATT}*))
cat << eof | sudo tee ${root_fs}/tmp/${cmd}
#!/bin/bash -x

rm -rf /tmp/*.cmd /tmp/*.inc /var/cache/apt /etc/apt/sources.list.d/yocto*
SRC=/ DST=${DEVICE} QUIET=Yes cl-deploy.work
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
_yocto_httpserver
}

function stage_http() {
yocto_httpserver
}

PROGNAME=${BASH_SOURCE[0]}
[ $(basename -- $BASH_SOURCE) == $(basename -- $0) ] && EXIT="exit" || EXIT="return"

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
images=${DIRNAME}/../images

INCLUDE=${PROGNAME:0:-3}"include"
[[ -f ${INCLUDE} ]] && . ${INCLUDE}

root_fs=${DIRNAME}/../rootfs/${distro[${name}]}-${name}-${arch}-${variant}

stages=${stages:-"1 2 3 4 5 6"}

trap stage_init INT QUIT TERM

stage_init

for s in ${stages};do
    ${copy_con}
    command -v stage_${s} &>/dev/null && stage_${s}
done
