export socarch=arm64

PACKAGES=""
PACKAGES_FORCE=""
FEATURES=${FEATURES:-"EMPTY;"}

function method_install() {
    PACKAGES+=${packages}" "
}

function method_decide() {
    ischroot && chroot_arch=$(dpkg --print-architecture) || chroot_arch=${socarch}
    [[ ${chroot_arch} = ${socarch} ]] && PACKAGES+=${packages}" " || PACKAGES_FORCE+=${packages}" "
}

function method_force() {
    PACKAGES_FORCE+=${packages}" "
}

function chroot_env() {
    for _p in ${OE2DEB[@]};do
        eval ${_p}
        packages=$(cat <<< ${packages} | tr ":" " ")
        packages=${packages} method_${method}
    done
}

function build_env() {
    for _p in ${!OE2DEB[@]};do
        PACKAGES+=${_p}" "
    done
}

declare -A OE2DEB=()

OE2DEB+=(['linux-imx']='method="install";packages="kernel:kernel-modules:kernel-devicetree:"')
OE2DEB+=(['firmware-imx']='method="install";packages="firmware-imx-sdma:"')

OE2DEB+=(['imx-boot']='method="install";packages="imx-boot:"')
OE2DEB+=(['alsa-state-compulab']='method="install";packages="alsa-state-compulab:"')
OE2DEB+=(['pulseaudio-compulab']='method="install";packages="pulseaudio-compulab:"')
OE2DEB+=(['firmware-cypress']='method="install";packages="firmware-cypress:"')
OE2DEB+=(['cl-deploy']='method="decide";packages="cl-deploy:"')
OE2DEB+=(['cl-uboot']='method="decide";packages="cl-uboot:"')
OE2DEB+=(['u-boot-imx-fw-utils']='method="force";packages="u-boot-imx-fw-utils:"')
OE2DEB+=(['eeprom-util']='method="force";packages="eeprom-util:"')
OE2DEB+=(['mbpoll']='method="force";packages="mbpoll:"')

if [[ ${FEATURES} =~ "GRUB" ]];then
OE2DEB+=(['u-boot-script']='method="install";packages="u-boot-script:"')
OE2DEB+=(['grub']='method="force";packages="grub-common:grub-editenv:grub-bootmod"')
OE2DEB+=(['grub-bootconf']='method="force";packages="grub-bootconf:"')
OE2DEB+=(['grub-efi']='method="force";packages="grub-efi:"')
OE2DEB+=(['cl-root']='method="force";packages="cl-root:"')
fi

ischroot && chroot_env || build_env

export PACKAGES=${PACKAGES}
export PACKAGES_FORCE=${PACKAGES_FORCE}
