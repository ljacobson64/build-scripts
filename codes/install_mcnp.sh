#!/bin/bash

set -e

build_prefix=${build_dir}/MCNP
install_prefix=${install_dir}/MCNP
if [ "${compiler}" == "native" ]; then
  build_prefix+=-gcc
  install_prefix+=-gcc
elif [ "${compiler}" == "intel" ]; then
  build_prefix+=-intel
  install_prefix+=-intel
fi

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
if   [ "${compiler}" == "native" ]; then openmpi_dir+=-gcc
elif [ "${compiler}" == "intel"  ]; then openmpi_dir+=-intel; fi
MPICC=${openmpi_dir}/bin/mpicc
MPICXX=${openmpi_dir}/bin/mpic++
MPIFC=${openmpi_dir}/bin/mpifort

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
git clone https://github.com/ljacobson64/MCNP_CMake -b main --single-branch
ln -sv MCNP_CMake src

cd MCNP_CMake
tar -xzvf ${dist_dir}/mcnp514-source.tar.gz
tar -xzvf ${dist_dir}/mcnp515-source.tar.gz
tar -xzvf ${dist_dir}/mcnp516-source.tar.gz
tar -xzvf ${dist_dir}/mcnpx27-source.tar.gz
tar -xzvf ${dist_dir}/mcnp602-source.tar.gz
tar -xzvf ${dist_dir}/mcnp610-source.tar.gz
tar -xzvf ${dist_dir}/mcnp611-source.tar.gz
tar -xzvf ${dist_dir}/mcnp620-source.tar.gz
cp -r MCNP514/Source MCNP514/Source_orig
cp -r MCNP515/Source MCNP515/Source_orig
cp -r MCNP516/Source MCNP516/Source_orig
cp -r MCNPX27/Source MCNPX27/Source_orig
cp -r MCNP602/Source MCNP602/Source_orig
cp -r MCNP610/Source MCNP610/Source_orig
cp -r MCNP611/Source MCNP611/Source_orig
cp -r MCNP620/Source MCNP620/Source_orig
./patch.sh

cd ../bld

cmake_string=
cmake_string+=" -DBUILD_MCNP514=ON"
cmake_string+=" -DBUILD_MCNP515=ON"
cmake_string+=" -DBUILD_MCNP516=ON"
cmake_string+=" -DBUILD_MCNPX27=ON"
cmake_string+=" -DBUILD_MCNP602=ON"
cmake_string+=" -DBUILD_MCNP610=ON"
cmake_string+=" -DBUILD_MCNP611=ON"
cmake_string+=" -DBUILD_MCNP620=ON"
cmake_string+=" -DBUILD_PLOT=ON"
if [ "${compiler}" == "intel" ]; then
  cmake_string+=" -DBUILD_OPENMP=ON"
  cmake_string+=" -DOpenMP_gcc_LIBRARY=gomp"
  cmake_string+=" -DOpenMP_dl_LIBRARY=/usr/lib/x86_64-linux-gnu/libdl.a"
  cmake_string+=" -DOpenMP_pthread_LIBRARY=/usr/lib/x86_64-linux-gnu/libpthread.a"
  cmake_string+=" -DOpenMP_irc_s_LIBRARY=${intel_dir}/compiler/lib/intel64/libirc_s.a"
  cmake_string+=" -DOpenMP_ipgo_LIBRARY=${intel_dir}/compiler/lib/intel64/libipgo.a"
  cmake_string+=" -DOpenMP_decimal_LIBRARY=${intel_dir}/compiler/lib/intel64/libdecimal.a"
fi
cmake_string+=" -DBUILD_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${MPICC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${MPICXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${MPIFC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
