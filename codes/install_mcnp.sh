#!/bin/bash

set -e

build_prefix=${build_dir}/MCNP
install_prefix=${install_dir}/MCNP
if [ "${compiler}" == "intel" ]; then
  build_prefix+=-intel
  install_prefix+=-intel
fi

if [ "$(hostname -s)" == "hpclogin2" ] && [ "${compiler}" == "gcc-9" ]; then
  module load openmpi/4.0.5-gcc930
  openmpi_dir=${EBROOTOPENMPI}
else
  openmpi_dir=${install_dir}/openmpi-${openmpi_version}
  if [ "${compiler}" == "intel" ]; then
    openmpi_dir+=-intel
  fi
fi
CC=${openmpi_dir}/bin/mpicc
CXX=${openmpi_dir}/bin/mpic++
FC=${openmpi_dir}/bin/mpifort

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/ljacobson64/MCNP_CMake -b main --single-branch
ln -sv MCNP_CMake src
cd MCNP_CMake
./mcnp_source.sh
cd ../bld

rpath_dirs=${openmpi_dir}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DBUILD_MCNP514=ON"
cmake_string+=" -DBUILD_MCNP515=ON"
cmake_string+=" -DBUILD_MCNP516=ON"
cmake_string+=" -DBUILD_MCNPX27=ON"
cmake_string+=" -DBUILD_MCNP602=ON"
cmake_string+=" -DBUILD_MCNP610=ON"
cmake_string+=" -DBUILD_MCNP611=ON"
cmake_string+=" -DBUILD_MCNP620=ON"
if [ "${system_has_x11}" == "true" ]; then
  cmake_string+=" -DBUILD_PLOT=ON"
fi
if [ "${compiler}" == "intel" ]; then
  cmake_string+=" -DBUILD_OPENMP=ON"
  cmake_string+=" -DOpenMP_gcc_LIBRARY=gomp"
  cmake_string+=" -DOpenMP_decimal_LIBRARY=${intel_dir}/compiler/latest/linux/compiler/lib/intel64/libdecimal.a"
  cmake_string+=" -DOpenMP_ipgo_LIBRARY=${intel_dir}/compiler/latest/linux/compiler/lib/intel64/libipgo.a"
  cmake_string+=" -DOpenMP_irc_s_LIBRARY=${intel_dir}/compiler/latest/linux/compiler/lib/intel64/libirc_s.a"
fi
cmake_string+=" -DBUILD_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
