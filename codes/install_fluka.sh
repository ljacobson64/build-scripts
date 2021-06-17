#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

if [ "${fluka_version}" == "2011.2x" ] || [ "${fluka_version}" == "2020.0" ]; then
  ${sudo_cmd_install} rm -rfv ${install_prefix}
  ${sudo_cmd_install} mkdir -pv ${install_prefix}/bin
  cd ${install_prefix}/bin
  tarball=fluka${fluka_version}-linux-gfor64bit-9.3-AA.tar.gz
  ${sudo_cmd_install} tar -xzvf ${dist_dir}/fluka/${tarball}

  export FLUFOR=$(basename $FC)
  export FLUPRO=${PWD}
  if [ -z "${sudo_cmd_install}" ]; then
    ${sudo_cmd_install} make
  else
    ${sudo_cmd_install} --preserve-env=FLUFOR,FLUPRO make
  fi
else  # Fluka 4
  ${sudo_cmd_install} rm -rfv ${install_prefix}
  ${sudo_cmd_install} mkdir -pv ${install_prefix}
  cd ${install_prefix}
  tarball=fluka-${fluka_version}.Linux-gfor9.tgz
  ${sudo_cmd_install} tar -xzvf ${dist_dir}/fluka/${tarball} --strip-components=1

  # Note: make will not find any custom compilers if sudo is being used
  cd src
  ${sudo_cmd_install} make -j${num_cpus}
fi
