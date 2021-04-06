export socarch=arm64

declare -A OE2DEB=()

OE2DEB+=(['linux-imx']='method="install";packages="kernel:kernel-modules:kernel-devicetree:"')
OE2DEB+=(['firmware-imx']='method="install";packages="firmware-imx-sdma:"')
OE2DEB+=(['linux-firmware']='method="install";packages="linux-firmware-iwlwifi-8265:linux-firmware-iwlwifi-license:linux-firmware-ibt-12-16:linux-firmware-ibt-license:linux-firmware-ibt-misc:");

OE2DEB+=(['imx-boot']='method="install";packages="imx-boot:"')
OE2DEB+=(['cl-deploy']='method="decide";packages="cl-deploy:"')
OE2DEB+=(['cl-uboot']='method="decide";packages="cl-uboot:"')
