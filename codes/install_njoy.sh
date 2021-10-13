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

rpath_dirs=${install_prefix}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
