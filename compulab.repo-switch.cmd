#!/bin/bash -ex

if [[ $1 == 'DEBIAN' ]];then
CONF=Debian
ECONF=/etc/apt/sources.list
DCONF=/etc/apt/sources.list.d/yocto.list
else
CONF=Yocto
ECONF=/etc/apt/sources.list.d/yocto.list
DCONF=/etc/apt/sources.list
fi

sed -i 's/^#//g' ${ECONF} ; sed -i 's/^d/#d/g' ${DCONF}

echo ${CONF}
cat ${ECONF} ${DCONF}
