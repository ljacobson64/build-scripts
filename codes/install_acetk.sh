#!/bin/bash

set -e

build_prefix=${build_dir}/ACEtk
install_prefix=${install_dir}/ACEtk

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/njoy/ACEtk -b fix/dependency-pybind11 --single-branch
ln -sv ACEtk src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
cp -pv ACEtk.cpython-38-x86_64-linux-gnu.so ${install_prefix}/lib/
