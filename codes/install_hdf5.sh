#!/bin/bash

set -e

build_prefix=${build_dir}/hdf5-${hdf5_version}
install_prefix=${install_dir}/hdf5-${hdf5_version}
if [ "${compiler}" == "intel" ]; then
  build_prefix+=-intel
  install_prefix+=-intel
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=hdf5-${hdf5_version}.tar.gz
hdf5_version_major=$(echo ${hdf5_version} | cut -f1,2 -d'.')
url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_version_major}/hdf5-${hdf5_version}/src/${tarball}
if [ ! -f ${dist_dir}/hdf5/${tarball} ]; then wget ${url} -P ${dist_dir}/hdf5/; fi
tar -xzvf ${dist_dir}/hdf5/${tarball}
ln -sv hdf5-${hdf5_version} src
cd bld

config_string=
config_string+=" --enable-cxx"
config_string+=" --enable-fortran"
if [ "${system_has_java}" == "true" ]; then
  config_string+=" --enable-java"
fi
config_string+=" --enable-shared"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}"
fi

../src/configure ${config_string}
make -j${num_cpus}
make -j${num_cpus} install
