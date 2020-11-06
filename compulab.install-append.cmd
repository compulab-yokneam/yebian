#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive

PACKAGES="kernel
	kernel-modules
	kernel-devicetree
	firmware-imx-sdma
	linux-firmware-ax200
	cl-uboot
	cl-deploy
	u-boot-imx-fw-utils
	eeprom-util
	mbpoll
"

export DEBIAN_FRONTEND=noninteractive

apt update

apt-get install --yes --no-install-recommends ${PACKAGES}
