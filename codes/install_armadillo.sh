#!/bin/bash

set -e

build_prefix=${build_dir}/armadillo-${armadillo_version}
install_prefix=${install_dir}/armadillo-${armadillo_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=armadillo-${armadillo_version}.tar.xz
url=http://sourceforge.net/projects/arma/files/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xJvf ${dist_dir}/misc/${tarball}
ln -s armadillo-${armadillo_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string_static=${cmake_string}
cmake_string_shared=${cmake_string}
cmake_string_static+=" -DBUILD_SHARED_LIBS=OFF"
cmake_string_shared+=" -DBUILD_SHARED_LIBS=ON"

cmake ../src ${cmake_string_static}
make -j${jobs}
${sudo_cmd} make install
cd ..; rm -rf bld; mkdir -p bld; cd bld
cmake ../src ${cmake_string_shared}
make -j${jobs}
${sudo_cmd} make install
