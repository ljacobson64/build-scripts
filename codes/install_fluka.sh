#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

if [[ "${fluka_version}" == "20"* ]]; then
  rm -rfv ${install_prefix}
  mkdir -pv ${install_prefix}/bin
  cd ${install_prefix}/bin
  if [[ "${fluka_version}" == "2021"* ]]; then
    tarball=fluka${fluka_version}-linux-gfor64bit-9.4-AA.tar.gz
  elif [[ "${fluka_version}" == "2020"* ]]; then
    tarball=fluka${fluka_version}-linux-gfor64bit-9.3-AA.tar.gz
  elif [[ "${fluka_version}" == "2011"* ]]; then
    tarball=fluka${fluka_version}-linux-gfor64bit-7.4-AA.tar.gz
  fi
  tar -xzvf ${dist_dir}/fluka/${tarball}
  export FLUFOR=$(basename $FC)
  export FLUPRO=${PWD}
  make
else  # Fluka 4
  rm -rfv ${install_prefix}
  mkdir -pv ${install_prefix}
  cd ${install_prefix}
  if [[ "${fluka_version}" == "4-1"* ]]; then
    tarball=fluka-${fluka_version}.Linux-gfor9.tgz
  else
    tarball=fluka-${fluka_version}.x86-Linux-gfor9.tgz
  fi
  tar -xzvf ${dist_dir}/fluka/${tarball} --strip-components=1
  cd src
  make -j${num_cpus}
fi
