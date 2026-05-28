#!/bin/bash

set -e

build_prefix=${build_dir}/isc-${isc_version}
install_prefix=${install_dir}/isc-${isc_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=isc-${isc_version}.zip
unzip ${dist_dir}/${tarball}
cd bld

cmake_string=""
cmake_string+=" -Disc.python_install=Prefix"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} .. ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
