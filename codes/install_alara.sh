#!/bin/bash

set -e

build_prefix=${build_dir}/ALARA
install_prefix=${install_dir}/ALARA

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/svalinn/ALARA -b main --single-branch
ln -sv ALARA src
cd ALARA
autoreconf -fi
cd ../bld

config_string=
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}"
fi

../src/configure ${config_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install
