#!/bin/bash

set -e

build_prefix=${build_dir}/boost-${boost_version}
install_prefix=${native_dir}/boost-${boost_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
boost_version_with_underscores=${boost_version//./_}
tarball=boost_${boost_version_with_underscores}.tar.gz
url=https://dl.bintray.com/boostorg/release/${boost_version}/source/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd boost_${boost_version_with_underscores}

./bootstrap.sh --prefix=${install_prefix}
echo >> project-config.jam
echo "using mpi : ${openmpi_dir}/bin/mpicc ;" >> project-config.jam
${sudo_cmd_native} ./b2 link=shared runtime-link=shared linkflags="-Wl,-rpath,${install_prefix}/lib" -j ${jobs} install
