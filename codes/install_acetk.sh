#!/bin/bash

set -e

build_prefix=${build_dir}/ACEtk-${acetk_version}
install_prefix=${install_dir}/ACEtk-${acetk_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
git clone https://github.com/njoy/ACEtk -b v${acetk_version} --single-branch
ln -sv ACEtk src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
mkdir -pv ${install_prefix}/lib
cp -pv python/ACEtk.cpython-312-x86_64-linux-gnu.so ${install_prefix}/lib/
