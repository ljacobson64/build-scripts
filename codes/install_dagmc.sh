#!/bin/bash

set -e

export geant4_version=10.05.p01

build_prefix=${build_dir}/DAGMC-moab-${moab_version}
install_prefix=${install_dir}/DAGMC-moab-${moab_version}
if [ "${compiler}" == "intel" ]; then
  build_prefix+=-intel
  install_prefix+=-intel
fi

eigen_dir=${install_dir}/eigen-${eigen_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}
fluka_dir=${install_dir}/fluka-${fluka_version}
geant4_dir=${install_dir}/geant4-${geant4_version}
if [ "${compiler}" == "intel" ]; then
  hdf5_dir+=-intel
  moab_dir+=-intel
  fluka_dir+=-intel
  geant4_dir+=-intel
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

install_dagmcnp5=true
install_dagmcnp6=true

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/svalinn/DAGMC -b develop --single-branch
ln -sv DAGMC src
cd DAGMC
if [ "${install_dagmcnp5}" == "true" ]; then
  cd src/mcnp/mcnp5
  tar -xzvf ${dist_dir}/mcnp/mcnp516-source.tar.gz --strip-components=1
  patch -p0 < patch/mcnp516.patch
  cd ../../..
fi
if [ "${install_dagmcnp6}" == "true" ]; then
  cd src/mcnp/mcnp6
  tar -xzvf ${dist_dir}/mcnp/mcnp620-source.tar.gz --strip-components=1
  patch -p0 < patch/mcnp620.patch
  cd ../../..
fi
if [ "${install_fludag}" == "true" ]; then
  if [ ! -f ${fluka_dir}/bin/flutil/rfluka.orig ]; then
    if [ "${fluka_version}" == "2011.2x" ] || [ "${fluka_version}" == "2020.0" ]; then
      patch -Nb ${fluka_dir}/bin/flutil/rfluka src/fluka/rfluka.patch
    else  # Fluka 4
      patch -Nb ${fluka_dir}/bin/rfluka src/fluka/rfluka.patch
    fi
  fi
fi
cd ../bld

cmake_string=
if [ "${custom_eigen}" == "true" ]; then
  cmake_string+=" -DEigen3_DIR=${eigen_dir}/share/eigen3/cmake"
fi
cmake_string+=" -DMOAB_DIR=${moab_dir}"
if [ "${install_dagmcnp5}" == "true" ]; then
  cmake_string+=" -DBUILD_MCNP5=ON"
fi
if [ "${install_dagmcnp6}" == "true" ]; then
  cmake_string+=" -DBUILD_MCNP6=ON"
fi
if [ "${install_fludag}" == "true" ]; then
  cmake_string+=" -DBUILD_FLUKA=ON"
  cmake_string+=" -DFLUKA_DIR=${fluka_dir}/bin"
fi
if [ "${install_daggeant4}" == "true" ]; then
  cmake_string+=" -DBUILD_GEANT4=ON"
  cmake_string+=" -DGEANT4_DIR=${geant4_dir}"
fi
if [ "${system_has_x11}" == "true" ]; then
  cmake_string+=" -DBUILD_MCNP_PLOT=ON"
fi
#cmake_string+=" -DBUILD_MCNP_OPENMP=ON"
cmake_string+=" -DBUILD_MCNP_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DBUILD_MCNP_PYNE_SOURCE=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_rpath_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
