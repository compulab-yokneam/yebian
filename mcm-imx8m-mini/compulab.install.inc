export socarch=arm64

declare -A OE2DEB=(['linux-imx']="kernel kernel-modules kernel-devicetree" ['firmware-imx']="firmware-imx-sdma")

_PACKAGES=" imx-boot alsa-state-compulab pulseaudio-compulab firmware-cypress "

PACKAGES_SOCARC=" cl-deploy cl-uboot "
PACKAGES_FORCE=" u-boot-imx-fw-utils eeprom-util mbpoll "

ischroot && chroot_arch=$(dpkg --print-architecture) || chroot_arch=${socarch}

[[ ${chroot_arch} = ${socarch} ]] && _PACKAGES+=${PACKAGES_SOCARC} || PACKAGES_FORCE+=${PACKAGES_SOCARC}

PACKAGES="${_PACKAGES} ${OE2DEB[linux-imx]} ${OE2DEB[firmware-imx]}"
OEPACKAGES="${_PACKAGES} ${PACKAGES_FORCE} linux-imx firmware-imx"
