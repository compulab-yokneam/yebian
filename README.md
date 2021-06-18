# yebian

## Linux kernel and device tree force update example.

* Update the machine **${MACHINE}/compulab.install.inc** file.

This is an [mcm-imx8m-mini/compulab.install.inc](https://raw.githubusercontent.com/compulab-yokneam/yebian/master/mcm-imx8m-mini/compulab.install.inc) file:
```
OE2DEB+=(['kernel']='method="reinstall";packages="kernel:"')
OE2DEB+=(['kernel-devicetree']='method="reinstall";packages="kernel-devicetree:"')
```

* Issue these commands in order to update and recreate the image.
```
bitbake linux-imx -c cleansstate
bitbake linux-imx
stages="4 5" ${BUILDDIR}/tmp/deploy/images/${MACHINE}/yebian/scripts/debian.cmd
```
