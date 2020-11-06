#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive

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

apt-get install --yes --no-install-recommends ${PACKAGES}

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian buster stable"

apt-get update

apt-get install --yes --no-install-recommends ${DOCKERS_PACKAGES}

update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
