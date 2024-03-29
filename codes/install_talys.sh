#!/bin/bash

set -e

build_prefix=${build_dir}/TALYS-${talys_version}
install_prefix=${install_dir}/TALYS-${talys_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=talys-${talys_version}-source.tgz
tar -xzvf ${dist_dir}/talys/${tarball}
ln -sv talys/source src

talyspath=`echo ${install_prefix}/ | sed 's/\//\\\\\//g'`
cd talys/source
rm -f ._*.f
sed -i "s/ home='.*'/ home='${talyspath}'/; s/60/132/" machine.f
sed -i "s/60 path/132 path/" talys.cmb
sed -i "s/90/162/" fissionpar.f
echo "project(talys Fortran)"                   >> CMakeLists.txt
echo "cmake_minimum_required(VERSION 2.8)"      >> CMakeLists.txt
echo "set(CMAKE_BUILD_TYPE Release)"            >> CMakeLists.txt
echo "set(CMAKE_Fortran_FLAGS_RELEASE \"-O1\")" >> CMakeLists.txt
echo "file(GLOB SRC_FILES \"*.f\")"             >> CMakeLists.txt
echo "add_executable(talys \${SRC_FILES})"      >> CMakeLists.txt
echo "install(TARGETS talys DESTINATION bin)"   >> CMakeLists.txt
cd ../../bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_rpath_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_rpath_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

mkdir -p ${install_prefix}/talys
cp -rpv ../talys/* ${install_prefix}/talys/

cd ${install_prefix}
tar -xzvf ${dist_dir}/talys/talys-${talys_version}-samples.tgz
tar -xzvf ${dist_dir}/talys/talys-${talys_version}-data.tgz
