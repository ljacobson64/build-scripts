#!/bin/bash

set -e

build_prefix=${build_dir}/python-${python_version_major}
install_prefix=${install_dir}/python-${python_version_major}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=Python-${python_version}.tgz
url=https://www.python.org/ftp/python/${python_version}/${tarball}
if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}/; fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv Python-${python_version} src
cd bld

rpath_dirs=${install_prefix}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

config_string=
config_string+=" --enable-shared"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${rpath_dirs}"

../src/configure ${config_string}
make -j${num_cpus}
make -j${num_cpus} install
