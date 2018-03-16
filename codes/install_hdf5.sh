#!/bin/bash

set -e

build_prefix=${build_dir}/hdf5-${hdf5_version}
install_prefix=${install_dir}/hdf5-${hdf5_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
tarball=hdf5-${hdf5_version}.tar.gz
if   [ "${hdf5_version:3:1}" == "." ]; then hdf5_version_major=${hdf5_version::3}
elif [ "${hdf5_version:4:1}" == "." ]; then hdf5_version_major=${hdf5_version::4}
fi
url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_version_major}/hdf5-${hdf5_version}/src/${tarball}
if [ ! -f ${dist_dir}/hdf5/${tarball} ]; then wget ${url} -P ${dist_dir}/hdf5/; fi
tar -xzvf ${dist_dir}/hdf5/${tarball}
ln -s hdf5-${hdf5_version} src
cd bld

config_string=
config_string+=" --enable-shared"
#config_string+=" --disable-debug"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd} make install
