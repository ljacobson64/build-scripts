#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

${sudo_cmd} rm -rf ${install_prefix}
${sudo_cmd} mkdir -p ${install_prefix}/bin
cd ${install_prefix}/bin
tarball=fluka${fluka_version}-linux-gfor64bitAA.tar.gz
${sudo_cmd} tar -xzvf ${dist_dir}/misc/${tarball}

export FLUFOR=gfortran
export FLUPRO=${PWD}

${sudo_cmd} make
