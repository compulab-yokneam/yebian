declare -A OE2DEB=(['linux-imx']="kernel kernel-modules kernel-devicetree" ['firmware-imx']="firmware-imx-sdma firmware-imx-brcm")

_PACKAGES="cl-uboot
	cl-deploy
	alsa-state-compulab
	pulseaudio-compulab
"

PACKAGES_FORCE="u-boot-imx-fw-utils
	eeprom-util
	mbpoll
"

PACKAGES="${_PACKAGES} ${OE2DEB[linux-imx]} ${OE2DEB[firmware-imx]}"
OEPACKAGES="${_PACKAGES} ${PACKAGES_FORCE} linux-imx firmware-imx"
