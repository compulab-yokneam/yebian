#!/bin/bash -ex

PACKAGES="alsa-utils  
	apt-utils  
	bluez  
	bsdmainutils  
	bzip2  
	can-utils  
	dbus  
	dialog  
	dosfstools  
	dnsmasq
	ethtool  
	fbset  
	fdisk  
	file  
	gpiod
	gpsd  
	gpsd-clients  
	hdparm  
	i2c-tools  
	ifupdown  
	iperf3  
	iputils-ping  
	isc-dhcp-client  
	iw  
	kmod  
	less  
	libparted2  
	libqmi-utils  
	minicom  
	mmc-utils  
	modemmanager  
	mtd-utils  
	netbase  
	net-tools  
	network-manager  
	nfs-common  
	ntpdate  
	openssh-client  
	openssh-server  
	parted  
	pciutils  
	psmisc  
	pulseaudio  
	pulseaudio-module-bluetooth  
	pv  
	python3  
	sudo  
	systemd  
	systemd-sysv  
	tmux  
	u-boot-tools  
	udev  
	usbutils  
	vim  
	wireless-tools  
	wpasupplicant  
	wvdial  
	xterm
	xz-utils  
"

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y locales
locale > /dev/null 
locale-gen en_US.UTF-8
dpkg-reconfigure locales

apt-get install --yes --no-install-recommends ${PACKAGES}

NCFG='/etc/NetworkManager/NetworkManager.conf'
if [[ -f ${NCFG} ]];then
sed -i '/\[main\]/a dns=dnsmasq' ${NCFG}
fi
