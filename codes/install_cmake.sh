#!/bin/bash

set -e

build_prefix=${build_dir}/cmake-${cmake_version}
install_prefix=${native_dir}/cmake-${cmake_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=cmake-${cmake_version}.tar.gz
if   [ "${cmake_version:3:1}" == "." ]; then cmake_version_major=${cmake_version::3}
elif [ "${cmake_version:4:1}" == "." ]; then cmake_version_major=${cmake_version::4}
fi
url=https://cmake.org/files/v${version_major}/${tarball}
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
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_native} make -j${jobs} install
