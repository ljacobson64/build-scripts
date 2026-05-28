#!/bin/bash

set -e

build_prefix=${build_dir}/acetk-${acetk_version}
install_prefix=${install_dir}/acetk-${acetk_version}

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
if [ -n "${compiler_rpath_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"
  sed -i "s/ INSTALL_RPATH \"/ INSTALL_RPATH \"\${CMAKE_INSTALL_RPATH}:/" ../ACEtk/python/CMakeLists.txt
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
ln -sv ${install_prefix}/lib/python${python_version_major}/site-packages/ACEtk.cpython-${python_version_major/.}-x86_64-linux-gnu.so ${install_prefix}/lib/
