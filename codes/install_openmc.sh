#!/bin/bash

set -e

build_prefix=${build_dir}/openmc-${openmc_version}
install_prefix=${install_dir}/openmc-${openmc_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}-gcc
MPICC=${openmpi_dir}/bin/mpicc
MPICXX=${openmpi_dir}/bin/mpic++

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
git clone https://github.com/openmc-dev/openmc -b v${openmc_version} --single-branch
ln -sv openmc src
cd bld

cmake_string=
cmake_string+=" -DOPENMC_USE_OPENMP=ON"
cmake_string+=" -DOPENMC_USE_MPI=ON"
cmake_string+=" -DHDF5_PREFER_PARALLEL=OFF"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${MPICC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${MPICXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

cd ../openmc
python -m pip -v install --prefix ${install_prefix} .

cd ${install_prefix}
dirs="bin include lib/cmake lib/pkgconfig lib/python3.12/site-packages share/doc share/man/man1"
files="lib/*.a lib/*.so"
for d in ${dirs}; do
  mkdir -pv ${python_dir}/${d}
  ln -svf ${install_prefix}/${d}/* ${python_dir}/${d}
done
for f in ${files}; do
  ln -svf ${install_prefix}/${f} ${python_dir}/${f}
done
