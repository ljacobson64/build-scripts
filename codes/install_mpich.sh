#!/bin/bash

set -e

build_prefix=${build_dir}/mpich-${mpich_version}
install_prefix=${install_dir}/mpich-${mpich_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=mpich-${mpich_version}.tar.gz
url=http://www.mpich.org/static/downloads/${mpich_version}/${tarball}
if [ ! -f ${dist_dir}/mpich/${tarball} ]; then wget ${url} -P ${dist_dir}/mpich/; fi
tar -xzvf ${dist_dir}/mpich/${tarball}
ln -sv mpich-${mpich_version} src
cd bld

LIBS=

config_string=
config_string+=" --enable-cxx"
config_string+=" --enable-fortran=yes"
config_string+=" --with-device=ch4:ofi"
config_string+=" --with-slurm=/usr"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC} LIBS=${LIBS}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}"
fi

../src/configure ${config_string}
make -j${num_cpus}
make -j${num_cpus} install
