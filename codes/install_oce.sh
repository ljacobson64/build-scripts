#!/bin/bash

set -e

build_prefix=${build_dir}/oce-${oce_version}
install_prefix=${install_dir}/oce-${oce_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=OCE-${oce_version}.tar.gz
url=https://github.com/tpaviot/oce/archive/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv oce-OCE-${oce_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DOCE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make -j${jobs} install
