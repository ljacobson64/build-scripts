#!/bin/bash

set -e

build_prefix=${build_dir}/cnpy
install_prefix=${install_dir}/cnpy

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/rogersce/cnpy -b master --single-branch
ln -sv cnpy src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${install_prefix}/lib"
else
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${install_prefix}/lib"
fi

${CMAKE} ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install
