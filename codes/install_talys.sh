#!/bin/bash

set -e

build_prefix=${build_dir}/TALYS-${talys_version}
install_prefix=${install_dir}/TALYS-${talys_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=talys-${talys_version}-source.tgz
tar -xzvf ${dist_dir}/${tarball}
ln -sv source src

talyspath=`echo ${install_prefix}/ | sed 's/\//\\\\\//g'`
cd source
sed -i "s/\/Users\/koning\/talys\//${talyspath}/" machine.f90

echo "cmake_minimum_required(VERSION 2.8)"      >> CMakeLists.txt
echo "project(talys Fortran)"                   >> CMakeLists.txt
echo "set(CMAKE_BUILD_TYPE Release)"            >> CMakeLists.txt
echo "set(CMAKE_Fortran_FLAGS_RELEASE \"-O1\")" >> CMakeLists.txt
echo "file(GLOB SRC_FILES \"*.f\" \"*.f90\")"   >> CMakeLists.txt
echo "add_executable(talys \${SRC_FILES})"      >> CMakeLists.txt
echo "install(TARGETS talys DESTINATION bin)"   >> CMakeLists.txt

cd ../bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

cd ..
cp -rpv doc misc source LICENSE README.md code_build path_change ${install_prefix}/

cd ${install_prefix}
tar -xzvf ${dist_dir}/talys-${talys_version}-samples.tgz
tar -xzvf ${dist_dir}/talys-${talys_version}-structure.tgz
