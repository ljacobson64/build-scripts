#!/bin/bash

set -e

build_prefix=${build_dir}/MCNPTOOLS-${mcnptools_version}
install_prefix=${install_dir}/MCNPTOOLS-${mcnptools_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/lanl/mcnptools -b main
cd mcnptools
git checkout v${mcnptools_version}
cd ..
ln -sv mcnptools src
cd bld

cmake_string_1=
cmake_string_1+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string_1+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string_1+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string_2=${cmake_string_1}
cmake_string_1+=" -Dmcnptools.python_install=Prefix"
cmake_string_2+=" -Dmcnptools.python_install=User"

${CMAKE} ../src ${cmake_string_1}
make -j${num_cpus}
make -j${num_cpus} install

${CMAKE} ../src ${cmake_string_2}
make -j${num_cpus}
make -j${num_cpus} install
