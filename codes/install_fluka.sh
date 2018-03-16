#!/bin/bash

set -e

install_prefix=${install_dir}/fluka-${fluka_version}

${SUDO} rm -rf ${install_prefix}
${SUDO} mkdir -p ${install_prefix}/bin
cd ${install_prefix}/bin
tarball=fluka${fluka_version}-linux-gfor64bitAA.tar.gz
${SUDO} tar -xzvf ${dist_dir}/misc/${tarball}

export FLUFOR=gfortran
export FLUPRO=${PWD}

${SUDO} make
