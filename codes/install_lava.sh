#!/bin/bash

set -e

build_prefix=${build_dir}/lava-${lava_version}
install_prefix=${install_dir}/lava-${lava_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=lava-${lava_version}.tar.gz
tar -xzvf ${dist_dir}/advantg/${tarball}
if [ "${lava_version}" == "1.1.1" ]; then
  ln -sv lava src
else
  ln -sv lava-${lava_version} src
fi
cd bld

cmake_string=
cmake_string+=" -DMCNP_VERSION=5.1.60"
cmake_string+=" -DMCNP_EXECUTABLE=${mcnp_exe}"
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
