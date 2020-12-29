#!/bin/bash

set -e

build_prefix=${build_dir}/cmake-${cmake_version}
install_prefix=${native_dir}/cmake-${cmake_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=cmake-${cmake_version}.tar.gz
cmake_version_major=$(echo ${cmake_version} | cut -f1,2 -d'.')
url=https://cmake.org/files/v${cmake_version_major}/${tarball}
if [ ! -f ${dist_dir}/cmake/${tarball} ]; then wget ${url} -P ${dist_dir}/cmake/; fi
tar -xzvf ${dist_dir}/cmake/${tarball}
ln -sv cmake-${cmake_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_rpath_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
${sudo_cmd_native} make -j${num_cpus} install
