#!/bin/bash

set -e

build_prefix=${build_dir}/MCNP
install_prefix=${install_dir}/MCNP

openmpi_dir=${install_dir}/openmpi-${openmpi_version}

CC=${openmpi_dir}/bin/mpicc
CXX=${openmpi_dir}/bin/mpic++
FC=${openmpi_dir}/bin/mpifort

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/ljacobson64/MCNP_CMake -b master --single-branch
ln -sv MCNP_CMake src
cd MCNP_CMake
./mcnp_source.sh
cd ../bld

cmake_string=
cmake_string+=" -DBUILD_MCNP514=ON"
cmake_string+=" -DBUILD_MCNP515=ON"
cmake_string+=" -DBUILD_MCNP516=ON"
if [ "${install_mcnpx27}" == "true" ]; then
  cmake_string+=" -DBUILD_MCNPX27=ON"
fi
cmake_string+=" -DBUILD_MCNP602=ON"
cmake_string+=" -DBUILD_MCNP610=ON"
cmake_string+=" -DBUILD_MCNP611=ON"
cmake_string+=" -DBUILD_PLOT=ON"
if [ "$(basename $FC)" == "ifort" ]; then
  cmake_string+=" -DBUILD_OPENMP=ON"
fi
cmake_string+=" -DBUILD_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${openmpi_dir}/lib"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make -j${jobs} install
