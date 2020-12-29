#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

${sudo_cmd_install} rm -rfv ${install_prefix}
${sudo_cmd_install} mkdir -pv ${install_prefix}/bin
cd ${install_prefix}/bin
${sudo_cmd_install} tar -xzvf ${dist_dir}/fluka/${fluka_tarball}

export FLUFOR=$(basename $FC)
export FLUPRO=${PWD}
if [ -z "${sudo_cmd_install}" ]; then
  ${sudo_cmd_install} make
else
  ${sudo_cmd_install} --preserve-env=FLUFOR,FLUPRO make
fi
