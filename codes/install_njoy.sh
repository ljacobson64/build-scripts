#!/bin/bash

set -e

build_prefix=${build_dir}/NJOY-${njoy_version}
install_prefix=${install_dir}/NJOY-${njoy_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=njoy-${njoy_version}.tar.gz
url=https://github.com/njoy/NJOY2016/archive/refs/tags/${njoy_version}.tar.gz
if [ ! -f ${dist_dir}/${tarball} ]; then
  wget ${url} -P ${dist_dir}/
  mv -v ${dist_dir}/${njoy_version}.tar.gz ${dist_dir}/${tarball}
fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv NJOY2016-${njoy_version} src
cd bld

rpath_dirs=${install_prefix}/lib

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
