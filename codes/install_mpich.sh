#!/bin/bash

set -e

build_prefix=${build_dir}/mpich-${mpich_version}
install_prefix=${install_dir}/mpich-${mpich_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=mpich-${mpich_version}.tar.gz
url=http://www.mpich.org/static/downloads/${version}/${tarball}
if [ ! -f ${dist_dir}/mpich/${tarball} ]; then wget ${url} -P ${dist_dir}/mpich/; fi
tar -xzvf ${dist_dir}/mpich/${tarball}
ln -s mpich-${mpich_version} src
cd bld

config_string=
if [ "${slurm_support}" == "true" ]; then
  config_string+=" --with-slurm=/usr"
  config_string+=" --with-pmi=pmi2"
  config_string+=" --with-pm=no"
  LIBS=-lpmi2
else
  LIBS=
fi
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC} LIBS=${LIBS}"

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd} make install
