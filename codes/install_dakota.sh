#!/bin/bash

set -e

build_prefix=${build_dir}/dakota-${dakota_version}
install_prefix=${install_dir}/dakota-${dakota_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=dakota-${dakota_version}-release-public.src-UI.tar.gz
url=https://dakota.sandia.gov/sites/default/files/distributions/public/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv dakota-${dakota_version}-release-public.src-UI src
cd bld

cmake_string=
cmake_string+=" -DDAKOTA_HAVE_MPI=TRUE"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DHAVE_QUESO=ON"
cmake_string+=" -DDAKOTA_HAVE_GSL=ON"
cmake_string+=" -DDAKOTA_HAVE_HDF5=ON"
cmake_string+=" -DHDF5_ROOT=${hdf5_dir}"
cmake_string+=" -DENABLE_DAKOTA_DOCS=TRUE"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install