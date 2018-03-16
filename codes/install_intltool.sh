#!/bin/bash

set -e

build_prefix=${build_dir}/intltool-${intltool_version}
install_prefix=${install_dir}/intltool-${intltool_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=intltool-${intltool_version}.tar.gz
url=https://launchpad.net/intltool/trunk/${version}/+download/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -s intltool-${intltool_version} src
cd bld

config_string=
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}"

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd} make install
