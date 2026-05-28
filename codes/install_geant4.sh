#!/bin/bash

set -e

build_prefix=${build_dir}/geant4-${geant4_version}
install_prefix=${install_dir}/geant4-${geant4_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=geant4-v${geant4_version}.tar.gz
url=https://gitlab.cern.ch/geant4/geant4/-/archive/v${geant4_version}/geant4-v${geant4_version}.tar.gz
if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}/; fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv geant4-v${geant4_version} src

sed -i "s/GEANT4_INSTALL_DATA_TIMEOUT 1500/GEANT4_INSTALL_DATA_TIMEOUT 3000/" src/cmake/Modules/G*4InstallData.cmake

cd bld

rpath_dirs=${install_prefix}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DGEANT4_BUILD_MULTITHREADED=ON"
cmake_string+=" -DGEANT4_BUILD_TLS_MODEL=global-dynamic"
cmake_string+=" -DGEANT4_INSTALL_DATA=ON"
cmake_string+=" -DGEANT4_USE_G3TOG4=ON"
cmake_string+=" -DGEANT4_USE_GDML=ON"
cmake_string+=" -DGEANT4_USE_OPENGL_X11=ON"
cmake_string+=" -DGEANT4_USE_QT=ON"
cmake_string+=" -DGEANT4_USE_RAYTRACER_X11=ON"
cmake_string+=" -DGEANT4_USE_XM=ON"
cmake_string+=" -DGEANT4_USE_PYTHON=ON"
cmake_string+=" -DGEANT4_INSTALL_DATASETS_TENDL=ON"
cmake_string+=" -DGEANT4_USE_SYSTEM_EXPAT=OFF"
cmake_string+=" -DBUILD_STATIC_LIBS=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
