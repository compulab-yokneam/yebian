declare -A OE2DEB=(['linux-imx']="kernel kernel-modules kernel-devicetree" ['firmware-imx']="firmware-imx-sdma" )

_PACKAGES="cl-uboot
	cl-deploy
"

PACKAGES_FORCE=" linux-firmware-iwlwifi-8265 linux-firmware-iwlwifi-license "
PACKAGES_FORCE+=" linux-firmware-ibt-12-16 linux-firmware-ibt-license linux-firmware-ibt-misc "

PACKAGES="${_PACKAGES} ${OE2DEB[linux-imx]} ${OE2DEB[firmware-imx]}"
OEPACKAGES="${_PACKAGES} linux-imx firmware-imx linux-firmware"
