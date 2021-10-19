#!/bin/bash

set -e

build_prefix=${build_dir}/root-${root_version}
install_prefix=${install_dir}/root-${root_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=root_v${root_version}.source.tar.gz
url=https://root.cern/download/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv root-${root_version} src
cd root-${root_version}
sed -i "s/set(CMAKE_SKIP_INSTALL_RPATH TRUE)/set(CMAKE_SKIP_INSTALL_RPATH FALSE)/" cmake/modules/RootBuildOptions.cmake
cd ../bld

rpath_dirs=${install_prefix}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -Dbuiltin_all=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
