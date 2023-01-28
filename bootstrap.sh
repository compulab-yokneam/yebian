#!/bin/bash -x

bootstrap=$(realpath ${BASH_SOURCE[0]})
base_dir=$(dirname $(dirname ${bootstrap}))/yebian-tools
BRANCH=devel-next
SRC_URI=https://github.com/compulab-yokneam/yebian-tools.git

if [[ -d ${base_dir}/.git ]];then
	git -C ${base_dir} remote update
	git -C ${base_dir} pull
else
	git clone -b ${BRANCH} ${SRC_URI} ${base_dir}
fi
