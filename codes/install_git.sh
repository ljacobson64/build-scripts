#!/bin/bash

set -e

build_prefix=${build_dir}/git-${git_version}
install_prefix=${install_dir}/git-${git_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}
cd ${build_prefix}
tarball=git-${git_version}.tar.gz
url=https://www.kernel.org/pub/software/scm/git/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd git-${git_version}

config_string=
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

./configure ${config_string}
make -j${jobs}
${SUDO} make install
