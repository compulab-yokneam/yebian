declare -A OE2DEB=(['linux-compulab']="kernel kernel-modules kernel-devicetree" ['firmware-imx']="firmware-imx-sdma")

_PACKAGES="cl-uboot
	cl-deploy
	u-boot-script-compulab
"
PACKAGES_FORCE=""

PACKAGES="${_PACKAGES} ${OE2DEB[linux-compulab]} ${OE2DEB[firmware-imx]}"
OEPACKAGES="${_PACKAGES} ${PACKAGES_FORCE} linux-compulab firmware-imx"
