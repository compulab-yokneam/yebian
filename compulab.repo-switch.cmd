#!/bin/bash

if [[ $1 == 'DEBIAN' ]];then
CONF=Debian
ECONF=/etc/apt/sources.list
DCONF=/etc/apt/sources.list.d/yocto.list
else
CONF=Yocto
ECONF=/etc/apt/sources.list.d/yocto.list
DCONF=/etc/apt/sources.list
fi

[[ -e ${ECONF} ]] && sed -i 's/^#//g' ${ECONF} || true
[[ -e ${DCONF} ]] && sed -i 's/^d/#d/g' ${DCONF} || true
