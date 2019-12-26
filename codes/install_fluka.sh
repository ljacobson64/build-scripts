#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

${sudo_cmd_install} rm -rfv ${install_prefix}
${sudo_cmd_install} mkdir -pv ${install_prefix}/bin
cd ${install_prefix}/bin
tarball=fluka${fluka_version}-linux-gfor64bitAA.tar.gz
${sudo_cmd_install} tar -xzvf ${dist_dir}/misc/${tarball}

if [ ! -z "${gcc_dir}" ]; then PATH=${gcc_dir}/bin:${PATH}; fi

${sudo_cmd_install} FLUFOR=$(basename $FC) FLUPRO=${PWD} make
