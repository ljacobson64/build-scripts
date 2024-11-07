#!/bin/bash

set -e

build_prefix=${build_dir}/ISC-${isc_version}
install_prefix=${install_dir}/ISC-${isc_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=isc-${isc_version}.zip
unzip ${dist_dir}/${tarball}
cd bld
${CMAKE} .. -Disc.python_install=Prefix \
            -DCMAKE_INSTALL_PREFIX=${install_prefix}
make -j${num_cpus}
make -j${num_cpus} install
