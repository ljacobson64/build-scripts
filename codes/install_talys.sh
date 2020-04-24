#!/bin/bash

set -e

build_prefix=${build_dir}/TALYS-${talys_version}
install_prefix=${native_dir}/TALYS-${talys_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball_code=talys${talys_version}_code.tar.gz
tarball_data=talys${talys_version}_data.tar.gz
tar -xzvf ${dist_dir}/talys/${tarball_code}
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
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}"
fi

${CMAKE} ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_native} make -j${jobs} install

cd ../talys
${sudo_cmd_native} cp -rpv LOG README doc samples source ${install_prefix}/talys/

cd ${install_prefix}
${sudo_cmd_native} tar -xzvf ${dist_dir}/talys/${tarball_data}
