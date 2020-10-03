#!/bin/bash

set -e

build_prefix=${build_dir}/NJOY${njoy_version}
install_prefix=${native_dir}/NJOY${njoy_version}

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
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${install_prefix}/lib"
else
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${install_prefix}/lib"
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
${sudo_cmd_native} make -j${num_cpus} install
