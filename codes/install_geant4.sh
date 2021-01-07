#!/bin/bash

set -e

build_prefix=${build_dir}/geant4-${geant4_version}
install_prefix=${install_dir}/geant4-${geant4_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=geant4.${geant4_version}.tar.gz
url=http://cern.ch/geant4-data/releases/${tarball}
if [ ! -f ${dist_dir}/geant4/${tarball} ]; then wget ${url} -P ${dist_dir}/geant4/; fi
tar -xzvf ${dist_dir}/geant4/${tarball}
ln -sv geant4.${geant4_version} src
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
if [ "${geant4_version}" != "10.05.p01" ]; then
  cmake_string+=" -DGEANT4_USE_PYTHON=ON"
fi
cmake_string+=" -DGEANT4_USE_SYSTEM_EXPAT=OFF"
cmake_string+=" -DBUILD_STATIC_LIBS=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install

cd ../src

if [ "${geant4_version}" == "10.05.p01" ]; then
  sed -i "s/g4ios.hh/G4ios.hh/" examples/extended/parallel/MPI/source/src/G4MPIextraWorker.cc
fi

cd ..
mkdir bld-mpi
cd bld-mpi

v1=$(echo ${geant4_version} | cut -f1,1 -d'.')
v2=$(echo ${geant4_version} | cut -f2,2 -d'.')
v3=$(echo ${geant4_version} | cut -f3,3 -d'.')
geant4_version_mod=${v1}.$((${v2})).$((${v3/p/}))

if [ "$(hostname -s)" == "hpclogin2" ] && [ "${compiler}" == "gcc-9" ]; then
  module load openmpi/4.0.5-gcc930
  openmpi_dir=${EBROOTOPENMPI}
else
  openmpi_dir=${install_dir}/openmpi-${openmpi_version}
fi
rpath_dirs=${rpath_dirs}:${openmpi_dir}/lib

cmake_string=
cmake_string+=" -DGeant4_DIR=${install_prefix}/lib/Geant4-${geant4_version_mod}"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DBUILD_STATIC_LIBS=ON"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src/examples/extended/parallel/MPI/source ${cmake_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install
