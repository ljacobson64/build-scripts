#!/bin/bash

set -e

build_prefix=${build_dir}/mcnptools-${mcnptools_version}
install_prefix=${install_dir}/mcnptools-${mcnptools_version}

export HDF5_DIR=/opt/software/hdf5-${hdf5_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=mcnptools-${mcnptools_version}.tar.gz
url=https://github.com/lanl/mcnptools/archive/refs/tags/v${mcnptools_version}.tar.gz
if [ ! -f ${dist_dir}/${tarball} ]; then
  wget ${url} -P ${dist_dir}/
  mv -v ${dist_dir}/v${mcnptools_version}.tar.gz ${dist_dir}/${tarball}
fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv mcnptools-${mcnptools_version} src
cd bld

rpath_dirs=${HDF5_DIR}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -Dmcnptools.python_install=Prefix"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
