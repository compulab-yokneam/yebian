declare -A OE2DEB=(['linux-imx']="kernel kernel-modules kernel-devicetree" ['firmware-imx']="firmware-imx-sdma")

_PACKAGES="linux-firmware-ax200
	cl-uboot
	cl-deploy
	u-boot-imx-fw-utils
	eeprom-util
	mbpoll
	alsa-state-compulab
	pulseaudio-compulab
"
PACKAGES="${_PACKAGES} ${OE2DEB[linux-imx]} ${OE2DEB[firmware-imx]}"
OEPACKAGES="${_PACKAGES} linux-imx firmware-imx"
