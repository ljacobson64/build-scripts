#!/bin/bash

set -e

build_prefix=${build_dir}/openmc-${openmc_version}
install_prefix=${install_dir}/openmc-${openmc_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
MPICC=${openmpi_dir}/bin/mpicc
MPICXX=${openmpi_dir}/bin/mpic++

hdf5_dir=/opt/software/hdf5-${hdf5_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
git clone https://github.com/openmc-dev/openmc -b v${openmc_version} --single-branch
ln -sv openmc src
cd bld

cmake_string=
cmake_string+=" -DOPENMC_USE_OPENMP=ON"
cmake_string+=" -DOPENMC_USE_MPI=ON"
cmake_string+=" -DHDF5_ROOT=${hdf5_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${MPICC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${MPICXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_rpath_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"
  sed -i "s/set(CMAKE_INSTALL_RPATH \"/set(CMAKE_INSTALL_RPATH \"\${CMAKE_INSTALL_RPATH}:/" ../openmc/CMakeLists.txt
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

cd ../openmc
python3 -m pip -v install --prefix ${install_prefix} .
