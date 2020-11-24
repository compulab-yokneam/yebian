#!/bin/bash -ex

USERS="compulab"
HOSTNAME="cl-debian"

function debian_locales_config() {
    locale > /dev/null
    locale-gen en_US.UTF-8
    dpkg-reconfigure locales
}

function debian_securetty_config() {
TTYS='ttyLP0 ttyLP1 ttyLP2 ttyLP3'
FILE2ADD2='/etc/securetty'
for TTY2ADD in ${TTYS};do
    grep -q ${TTY2ADD} ${FILE2ADD2} || sed -i "$ a ${TTY2ADD}" ${FILE2ADD2}
done
}

function debian_profiled_config() {
PROFILED='/etc/profile.d'
FILE2ADD2='resize.sh'
if [[ -d ${PROFILED} && ! -e ${PROFILED}/${FILE2ADD2} ]];then
cat << eof | tee ${PROFILED}/${FILE2ADD2}
shopt -s checkwinsize; resize
eof
fi
}

function debian_netman_config() {
    NCFG='/etc/NetworkManager/NetworkManager.conf'
    if [[ -f ${NCFG} ]];then
        sed -i '/\[main\]/a dns=dnsmasq' ${NCFG}
    fi
}

function debian_users_config() {
USER_GROUPS="audio,bluetooth,video,dialout,sudo"
passwd -d -e root

for USER2ADD in ${USERS};do

grep -q ${USER2ADD} /etc/passwd || useradd --create-home --shell /bin/bash ${USER2ADD}

usermod -aG ${USER_GROUPS} ${USER2ADD}

passwd ${USER2ADD} << eof
${USER2ADD}
${USER2ADD}
eof

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
debian_netman_config
debian_users_config
debian_hostname_config
debian_services_config
debian_securetty_config
debian_profiled_config
