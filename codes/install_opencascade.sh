#!/bin/bash

set -e

build_prefix=${build_dir}/opencascade-${opencascade_version}
install_prefix=${install_dir}/opencascade-${opencascade_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=opencascade-${opencascade_version}.tgz
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv opencascade-${opencascade_version} src
cd bld

rpath_dirs=${install_prefix}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
