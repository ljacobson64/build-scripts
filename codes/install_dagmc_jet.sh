#!/bin/bash

set -e

build_prefix=${build_dir}/DAGMC-JET-moab-${moab_version}
install_prefix=${install_dir}/DAGMC-JET-moab-${moab_version}

eigen_dir=${install_dir}/eigen-${eigen_version}
openmpi_dir=${install_dir}/openmpi-${openmpi_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}

CC=${openmpi_dir}/bin/mpicc
CXX=${openmpi_dir}/bin/mpic++
FC=${openmpi_dir}/bin/mpifort

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/svalinn/DAGMC -b develop --single-branch
ln -sv DAGMC src
cd DAGMC/src/mcnp/mcnp5
tar -xzvf ${dist_dir}/mcnp/mcnp516-source.tar.gz --strip-components=1
patch -p0 < patch/mcnp516.patch
cp -pv ${dist_dir}/mcnp/source_plasma.F90 Source/src/source.F90
cd ../../../../bld

cmake_string=
if [ "${native_eigen}" == "false" ]; then
  cmake_string+=" -DEigen3_DIR=${eigen_dir}/share/eigen3/cmake"
fi
cmake_string+=" -DMOAB_DIR=${moab_dir}"
cmake_string+=" -DBUILD_MCNP5=ON"
cmake_string+=" -DBUILD_MCNP_PLOT=ON"
#cmake_string+=" -DBUILD_MCNP_OPENMP=ON"
cmake_string+=" -DBUILD_MCNP_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DBUILD_MCNP_PYNE_SOURCE=OFF"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install
