#!/bin/bash

set -e

build_prefix=${build_dir}/lava-${lava_version}
install_prefix=${install_dir}/lava-${lava_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=lava-${lava_version}.tar.gz
tar -xzvf ${dist_dir}/misc/${tarball}
ln -s lava src
cd bld

cmake_string=
cmake_string+=" -DMCNP_VERSION=5.1.60"
cmake_string+=" -DMCNP_EXECUTABLE=${mcnp_exe}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string_static=${cmake_string}
cmake_string_shared=${cmake_string}
cmake_string_static+=" -DBUILD_SHARED_LIBS=OFF"
cmake_string_shared+=" -DBUILD_SHARED_LIBS=ON"

cmake ../src ${cmake_string_static}
make -j${jobs}
${SUDO} make install
cd ..; rm -rf bld; mkdir -p bld; cd bld
cmake ../src ${cmake_string_shared}
make -j${jobs}
${SUDO} make install
