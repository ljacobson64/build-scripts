#!/bin/bash

set -e

build_prefix=${build_dir}/hdf5-${hdf5_version}-parallel
install_prefix=${install_dir}/hdf5-${hdf5_version}-parallel

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
MPICC=${openmpi_dir}/bin/mpicc
MPICXX=${openmpi_dir}/bin/mpic++
MPIFC=${openmpi_dir}/bin/mpifort

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=hdf5-${hdf5_version}.tar.gz
hdf5_version_major=$(echo ${hdf5_version} | cut -f1,2 -d'.')
if [ "${hdf5_version_major}" == "1.14" ]; then
  url=https://support.hdfgroup.org/releases/hdf5/v${hdf5_version_major//\./_}/v${hdf5_version//\./_}/downloads/${tarball}
else
  url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_version_major}/hdf5-${hdf5_version}/src/${tarball}
fi
if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}/; fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv hdf5-${hdf5_version} src
cd bld

cmake_string=
cmake_string+=" -DHDF5_BUILD_FORTRAN=ON"
cmake_string+=" -DHDF5_BUILD_HL_LIB=ON"
cmake_string+=" -DHDF5_BUILD_TOOLS=ON"
cmake_string+=" -DHDF5_BUILD_HL_GIF_TOOLS=ON"
cmake_string+=" -DHDF5_ENABLE_PARALLEL=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${MPICC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${MPICXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${MPIFC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
