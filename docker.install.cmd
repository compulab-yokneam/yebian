#!/bin/bash -ex

PACKAGES="apt-transport-https
	ca-certificates
	curl
	gnupg
	gnupg-agent
	software-properties-common
"

DOCKERS_PACKAGES="docker-ce
	docker-ce-cli
	containerd.io
"

function docker_install() {
	apt-get install --yes --no-install-recommends ${PACKAGES}

	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

	apt-key fingerprint 0EBFCD88

	add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian buster stable"

	apt-get update

	apt-get install --yes --no-install-recommends ${DOCKERS_PACKAGES}

	update-alternatives --set iptables /usr/sbin/iptables-legacy
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
}

export DEBIAN_FRONTEND=noninteractive
PROGNAME=${BASH_SOURCE[0]}
INCLUDE=${PROGNAME:0:-3}"inc"

[[ -f ${INCLUDE} ]] && . ${INCLUDE}

dpkg -l docker-ce-cli &>/dev/null || docker_install
