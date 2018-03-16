#!/bin/bash

set -e

build_prefix=${build_dir}/pcre-${pcre_version}
install_prefix=${install_dir}/pcre-${pcre_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=pcre-${pcre_version}.tar.gz
url=https://sourceforge.net/projects/pcre/files/pcre/${pcre_version}/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -s pcre-${pcre_version} src
cd bld

config_string=
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}"

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd} make install
