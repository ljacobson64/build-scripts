#!/bin/bash

set -e

build_prefix=${build_dir}/silo-${silo_version}
install_prefix=${install_dir}/silo-${silo_version}

hdf5_dir=${install_dir}/hdf5-${hdf5_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=silo-${silo_version}.tar.gz
url=https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/silo/silo-${silo_version}/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv silo-${silo_version} src
cd bld

config_string=
config_string+=" --enable-shared"
config_string+=" --with-hdf5=${hdf5_dir}/include,${hdf5_dir}/lib"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_lib_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}"
fi

../src/configure ${config_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install
