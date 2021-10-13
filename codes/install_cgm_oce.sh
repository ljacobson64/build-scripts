#!/bin/bash

set -e

export cgm_version=16.0

build_prefix=${build_dir}/cgm-${cgm_version}-oce-${oce_version}
install_prefix=${install_dir}/cgm-${cgm_version}-oce-${oce_version}

oce_dir=${install_dir}/oce-${oce_version}

repo=https://bitbucket.org/fathomteam/cgm
branch=master

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone ${repo} -b ${branch} --single-branch
ln -sv cgm src
cd cgm
autoreconf -fi
cd ../bld

config_string=
config_string+=" --enable-shared"
config_string+=" --enable-optimize"
config_string+=" --disable-debug"
config_string+=" --with-occ=${oce_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}:${oce_dir}/lib"
else
  config_string+=" LDFLAGS=-Wl,-rpath,${oce_dir}/lib"
fi

../src/configure ${config_string}
make -j${num_cpus}
make -j${num_cpus} install
