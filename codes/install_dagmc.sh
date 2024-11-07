#!/bin/bash

set -e

build_prefix=${build_dir}/DAGMC-${dagmc_version}
install_prefix=${install_dir}/DAGMC-${dagmc_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}-gcc
MPICC=${openmpi_dir}/bin/mpicc
MPICXX=${openmpi_dir}/bin/mpic++
MPIFC=${openmpi_dir}/bin/mpifort

moab_dir=${install_dir}/moab-${moab_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
git clone https://github.com/svalinn/DAGMC -b ${dagmc_version} --single-branch
ln -sv DAGMC src
cd DAGMC
cd src/mcnp/mcnp5
tar -xzvf ${dist_dir}/mcnp516-source.tar.gz --strip-components=1
patch -p0 < patch/mcnp516.patch
cd ../../..
cd src/mcnp/mcnp6
tar -xzvf ${dist_dir}/mcnp620-source.tar.gz --strip-components=1
patch -p0 < patch/mcnp620.patch
cd ../../../../bld

cmake_string=
cmake_string+=" -DMOAB_DIR=${moab_dir}"
cmake_string+=" -DBUILD_MCNP5=ON"
cmake_string+=" -DBUILD_MCNP6=ON"
cmake_string+=" -DBUILD_MCNP_PLOT=ON"
cmake_string+=" -DBUILD_MCNP_OPENMP=OFF"
cmake_string+=" -DBUILD_MCNP_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DBUILD_MCNP_PYNE_SOURCE=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${MPICC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${MPICXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${MPIFC}"
cmake_string+=" -DCMAKE_Fortran_FLAGS=-fallow-argument-mismatch"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}

cd ../DAGMC/src/pyne
echo "extern \"C\" {
  void sampling_setup_(int* mode, int* cell_list_size) {
    pyne::sampling_setup_(mode, cell_list_size);
  }
  void particle_birth_(double* rands, double* x, double* y, double* z, double* e, double* w, int* cell_list) {
    pyne::particle_birth_(rands, x, y, z, e, w, cell_list);
  }
}" >> pyne.cpp
cd ../../../bld

make -j${num_cpus}
make -j${num_cpus} install
