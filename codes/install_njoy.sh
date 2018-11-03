#!/bin/bash

set -e

build_prefix=${build_dir}/NJOY${njoy_version}
install_prefix=${install_dir}/NJOY${njoy_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/njoy/NJOY${njoy_version} -b master --single-branch
ln -sv NJOY${njoy_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${install_prefix}/lib"

${CMAKE} ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make -j${jobs} install
