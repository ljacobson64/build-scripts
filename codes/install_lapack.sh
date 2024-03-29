#!/bin/bash

set -e

build_prefix=${build_dir}/lapack-${lapack_version}
install_prefix=${install_dir}/lapack-${lapack_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=lapack-${lapack_version}.tar.gz
url=https://github.com/Reference-LAPACK/lapack/archive/v${lapack_version}.tar.gz
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv -v ${dist_dir}/misc/v${lapack_version}.tar.gz ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv lapack-${lapack_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_rpath_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"
fi
cmake_string_static=${cmake_string}
cmake_string_shared=${cmake_string}
cmake_string_static+=" -DBUILD_SHARED_LIBS=OFF"
cmake_string_shared+=" -DBUILD_SHARED_LIBS=ON"

${CMAKE} ../src ${cmake_string_static}
make -j${num_cpus}
make -j${num_cpus} install
cd ..; rm -rfv bld; mkdir -pv bld; cd bld
${CMAKE} ../src ${cmake_string_shared}
make -j${num_cpus}
make -j${num_cpus} install
