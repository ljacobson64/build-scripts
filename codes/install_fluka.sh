#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

rm -rfv   ${install_prefix}
mkdir -pv ${install_prefix}
cd        ${install_prefix}
tarball=fluka-${fluka_version}.x86-Linux-gfor9.tgz
tar -xzvf ${dist_dir}/${tarball} --strip-components=1
cd src

make -j${num_cpus}
