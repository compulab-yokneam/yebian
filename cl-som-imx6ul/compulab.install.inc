declare -A OE2DEB=(['linux-compulab']="kernel kernel-modules kernel-devicetree" ['firmware-imx']="firmware-imx-sdma" ['linux-firmware']="linux-firmware-ti-connectivity-license linux-firmware-wl12xx linux-firmware-wl18xx")

_PACKAGES="cl-uboot
	cl-deploy
	u-boot-script-compulab
	uim-sysfs
"
PACKAGES_FORCE="${OE2DEB[linux-firmware]}"

PACKAGES="${_PACKAGES} ${OE2DEB[linux-compulab]} ${OE2DEB[firmware-imx]}"
OEPACKAGES="${_PACKAGES} linux-compulab firmware-imx linux-firmware"
