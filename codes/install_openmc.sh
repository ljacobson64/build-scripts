#!/bin/bash

set -e

build_prefix=${build_dir}/openmc-${openmc_version}
install_prefix=${install_dir}/openmc-${openmc_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
dagmc_dir=${install_dir}/DAGMC-moab-${moab_version}

CC=${openmpi_dir}/bin/mpicc
CXX=${openmpi_dir}/bin/mpic++

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/openmc-dev/openmc -b v${openmc_version} --single-branch
ln -sv openmc src
cd bld

cmake_string=
cmake_string+=" -Doptimize=ON"
cmake_string+=" -Dopenmp=ON"
cmake_string+=" -Ddagmc=ON"
cmake_string+=" -DHDF5_ROOT=${hdf5_dir}"
cmake_string+=" -DDAGMC_DIR=${dagmc_dir}/lib/cmake/dagmc"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

# Note: RPATH will not include path to compiler libraries if using custom compilers

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
