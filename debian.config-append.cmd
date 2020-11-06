#!/bin/bash -ex

USERS="compulab"
HOSTNAME="iot-gate-imx8"

passwd -d -e root

for USER2ADD in ${USERS};do

useradd --create-home --shell /bin/bash --groups sudo ${USER2ADD}

passwd ${USER2ADD} << eof
${USER2ADD}
${USER2ADD}
eof

done

sed -i "s/\(^127.0.0.1.*$\)/\1 ${HOSTNAME}/" /etc/hosts
echo ${HOSTNAME} > /etc/hostname

systemctl disable dnsmasq
