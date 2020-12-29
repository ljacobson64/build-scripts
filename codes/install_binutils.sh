#!/bin/bash

set -e

build_prefix=${build_dir}/binutils-${binutils_version}
install_prefix=${native_dir}/binutils-${binutils_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=binutils-${binutils_version}.tar.gz
url=https://ftp.gnu.org/gnu/binutils/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv binutils-${binutils_version} src
cd bld

config_string=
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}"
fi

../src/configure ${config_string}
make -j${num_cpus}
${sudo_cmd_native} make -j${num_cpus} install
