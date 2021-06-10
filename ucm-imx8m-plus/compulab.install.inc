export socarch=arm64

declare -A OE2DEB=()

OE2DEB+=(['linux-compulab']='method="install";packages="kernel:kernel-modules:kernel-devicetree:"')
OE2DEB+=(['firmware-imx']='method="install";packages="firmware-imx-sdma:firmware-imx-xcvr:firmware-imx-easrc"')

OE2DEB+=(['imx-boot']='method="install";packages="imx-boot:"')
OE2DEB+=(['alsa-state-compulab']='method="install";packages="alsa-state-compulab:"')
OE2DEB+=(['pulseaudio-compulab']='method="install";packages="pulseaudio-compulab:"')
OE2DEB+=(['cl-deploy']='method="decide";packages="cl-deploy:"')
OE2DEB+=(['cl-uboot']='method="decide";packages="cl-uboot:"')
OE2DEB+=(['u-boot-compulab-fw-utils']='method="force";packages="u-boot-compulab-fw-utils:"')

if [[ ${FEATURES} =~ "GRUB" ]];then
OE2DEB+=(['u-boot-script']='method="install";packages="u-boot-script:"')
OE2DEB+=(['grub']='method="install";packages="grub-common:grub-editenv:grub-bootmod"')
OE2DEB+=(['grub-bootconf']='method="install";packages="grub-bootconf:"')
OE2DEB+=(['grub-efi']='method="force";packages="grub-efi:"')
OE2DEB+=(['cl-root']='method="install";packages="cl-root:"')
fi
