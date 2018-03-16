#!/bin/bash

set -e

build_prefix=${build_dir}/cmake-${cmake_version}
install_prefix=${install_dir}/cmake-${cmake_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=cmake-${cmake_version}.tar.gz
if   [ "${cmake_version:3:1}" == "." ]; then cmake_version_major=${cmake_version::3}
elif [ "${cmake_version:4:1}" == "." ]; then cmake_version_major=${cmake_version::4}
fi
url=https://cmake.org/files/v${version_major}/${tarball}
if [ ! -f ${dist_dir}/cmake/${tarball} ]; then wget ${url} -P ${dist_dir}/cmake/; fi
tar -xzvf ${dist_dir}/cmake/${tarball}
ln -s cmake-${cmake_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make install
