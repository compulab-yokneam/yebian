#!/bin/bash -ex

USERS="compulab"
HOSTNAME="cl-debian"

function debian_locales_config() {
    locale > /dev/null
    locale-gen en_US.UTF-8
    dpkg-reconfigure locales
}

function debian_nn_config() {
    NCFG='/etc/NetworkManager/NetworkManager.conf'
    if [[ -f ${NCFG} ]];then
        sed -i '/\[main\]/a dns=dnsmasq' ${NCFG}
    fi
}

function debian_users_config() {
passwd -d -e root

for USER2ADD in ${USERS};do

grep -q ${USER2ADD} /etc/passwd
if [[ $? -eq 1 ]];then
useradd --create-home --shell /bin/bash --groups sudo ${USER2ADD}

passwd ${USER2ADD} << eof
${USER2ADD}
${USER2ADD}
eof

fi
done
}

function debian_hostname_config() {
sed -i "s/\(^127.0.0.1.*$\)/\1 ${HOSTNAME}/" /etc/hosts
echo ${HOSTNAME} > /etc/hostname
}


function debian_services_config() {
systemctl disable dnsmasq
}

export DEBIAN_FRONTEND=noninteractive
PROGNAME=${BASH_SOURCE[0]}
INCLUDE=${PROGNAME:0:-3}"inc"

[[ -f ${INCLUDE} ]] && . ${INCLUDE}

debian_locales_config
debian_nn_config
debian_users_config
debian_hostname_config
debian_services_config
