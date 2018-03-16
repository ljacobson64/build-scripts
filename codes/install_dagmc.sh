#!/bin/bash

set -e

build_prefix=${build_dir}/DAGMC-moab-${moab_version}
install_prefix=${install_dir}/DAGMC-moab-${moab_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}
fluka_dir=${install_dir}/fluka-${fluka_version}
geant4_dir=${install_dir}/geant4-${geant4_version}

PATH=${hdf5_dir}:${PATH}
LD_LIBRARY_PATH=${moab_dir}/lib:${LD_LIBRARY_PATH}

CC=${openmpi_dir}/bin/mpicc
CXX=${openmpi_dir}/bin/mpic++
FC=${openmpi_dir}/bin/mpifort

install_dagmcnp5=true
install_dagmcnp6=true

rm -rf ${build_prefix}
mkdir -p ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/svalinn/DAGMC -b develop --single-branch
ln -s DAGMC src
cd DAGMC
if [ "${install_dagmcnp5}" == "true" ]; then
  cd mcnp/mcnp5
  tar -xzvf ${dist_dir}/mcnp/mcnp516-source.tar.gz --strip-components=1
  patch -p0 < patch/dagmc.5.1.60.patch
  cd ../..
fi
if [ "${install_dagmcnp6}" == "true" ]; then
  cd mcnp/mcnp6
  tar -xzvf ${dist_dir}/mcnp/mcnp611-source.tar.gz --strip-components=1
  patch -p0 < patch/dagmc.6.1.1beta.patch
  cd ../..
fi
if [ "${install_fludag}" == "true" ]; then
  if [ ! -x ${fluka_dir}/bin/flutil/rfluka.orig ]; then
    patch -Nb ${fluka_dir}/bin/flutil/rfluka fluka/rfluka.patch
  fi
fi
cd ../bld

cmake_string=
rpath_string="${install_prefix}/lib;${openmpi_dir}/lib;${hdf5_dir}/lib;${moab_dir}/lib"
if [ "${install_dagmcnp5}" == "true" ]; then
  cmake_string+=" -DBUILD_MCNP5=ON"
  cmake_string+=" -DMCNP5_PLOT=ON"
fi
if [ "${install_dagmcnp6}" == "true" ]; then
  cmake_string+=" -DBUILD_MCNP6=ON"
  cmake_string+=" -DMCNP6_PLOT=ON"
fi
if [ "${install_fludag}" == "true" ]; then
  cmake_string+=" -DBUILD_FLUKA=ON"
  cmake_string+=" -DFLUKA_DIR=${fluka_dir}/bin"
  rpath_string+=";${fluka_dir}/lib"
fi
if [ "${install_daggeant4}" == "true" ]; then
  cmake_string+=" -DBUILD_GEANT4=ON"
  cmake_string+=" -DGEANT4_DIR=${geant4_dir}"
  rpath_string+=";${geant4_dir}/lib"
fi
cmake_string+=" -DMPI_BUILD=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_string}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make install
