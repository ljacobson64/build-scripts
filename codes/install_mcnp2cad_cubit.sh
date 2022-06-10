#!/bin/bash

set -e

export cgm_version=16.0
export cubit_version=14.0

build_prefix=${build_dir}/mcnp2cad-cgm-${cgm_version}-cubit-${cubit_version}
install_prefix=${install_dir}/mcnp2cad-cgm-${cgm_version}-cubit-${cubit_version}

cubit_dir=${install_dir}/cubit-${cubit_version}
cgm_dir=${install_dir}/cgm-${cgm_version}-cubit-${cubit_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/svalinn/mcnp2cad -b master --single-branch
ln -sv mcnp2cad src
cd bld

cmake_string=
cmake_string+=" -DIGEOM_DIR=${cgm_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Debug"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
