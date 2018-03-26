#!/bin/bash

set -e

build_prefix=${build_dir}/cgm-${cgm_version}
install_prefix=${install_dir}/cgm-${cgm_version}

cubit_dir=${install_dir}/cubit-${cgm_version}

if [ "${cgm_version}" == "14.0" ]; then
  repo=https://bitbucket.org/makeclean/cgm
  branch=add_torus_14
else
  repo=https://bitbucket.org/fathomteam/cgm
  branch=cgm${cgm_version}
fi

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
git clone ${repo} -b ${branch} --single-branch
ln -s cgm src
cd cgm
autoreconf -fi
cd ../bld

config_string=
config_string+=" --enable-shared"
config_string+=" --enable-optimize"
config_string+=" --disable-debug"
config_string+=" --with-cubit=${cubit_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_lib_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}"
fi

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd} make install
