#!/bin/bash

set -e

build_prefix=${build_dir}/moab-${moab_version}
install_prefix=${install_dir}/moab-${moab_version}

hdf5_dir=${install_dir}/hdf5-${hdf5_version}

if [ ${moab_version} == "master" ]; then
  branch=master
else
  branch=Version${moab_version}
fi

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
git clone https://bitbucket.org/fathomteam/moab -b ${branch} --single-branch
ln -s moab src
cd moab
autoreconf -fi
cd ../bld

config_string=
config_string+=" --disable-ahf"
config_string+=" --enable-shared"
config_string+=" --enable-optimize"
config_string+=" --disable-debug"
config_string+=" --with-hdf5=${hdf5_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${hdf5_dir}/lib"

../src/configure ${config_string}
make -j${jobs}
${SUDO} make install
