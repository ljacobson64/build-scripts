#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

if [[ "${fluka_version}" == "20"* ]]; then
  rm -rfv ${install_prefix}
  mkdir -pv ${install_prefix}/bin
  cd ${install_prefix}/bin
  tarball=fluka${fluka_version}-linux-gfor64bit-9.3-AA.tar.gz
  tar -xzvf ${dist_dir}/fluka/${tarball}
  export FLUFOR=$(basename $FC)
  export FLUPRO=${PWD}
  make
else  # Fluka 4
  rm -rfv ${install_prefix}
  mkdir -pv ${install_prefix}
  cd ${install_prefix}
  tarball=fluka-${fluka_version}.Linux-gfor9.tgz
  tar -xzvf ${dist_dir}/fluka/${tarball} --strip-components=1
  cd src
  make -j${num_cpus}
fi
