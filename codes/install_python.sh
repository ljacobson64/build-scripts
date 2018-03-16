#!/bin/bash

set -e

build_prefix=${build_dir}/python-${python_version}
install_prefix=${install_dir}/python-${python_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=Python-${python_version}.tgz
url=https://www.python.org/ftp/python/${python_version}/${tarball}
if [ ! -f ${dist_dir}/python/${tarball} ]; then wget ${url} -P ${dist_dir}/python/; fi
tar -xzvf ${dist_dir}/python/${tarball}
ln -s Python-${python_version} src
cd bld

config_string=
config_string+=" --enable-shared"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${install_prefix}/lib"

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd} make install
