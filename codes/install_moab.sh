#!/bin/bash

set -e

build_prefix=${build_dir}/moab-${moab_version}
install_prefix=${install_dir}/moab-${moab_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=moab-${moab_version}.tar.gz
url=https://bitbucket.org/fathomteam/moab/get/${moab_version}.tar.gz
if [ ! -f ${dist_dir}/${tarball} ]; then
  wget ${url} -P ${dist_dir}/
  mv -v ${dist_dir}/${moab_version}.tar.gz ${dist_dir}/${tarball}
fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv fathomteam-moab-* src
cd bld

rpath_dirs=${install_prefix}/lib

cmake_string_1=
cmake_string_1+=" -DENABLE_HDF5=ON"
cmake_string_1+=" -DENABLE_NETCDF=ON"
cmake_string_1+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string_1+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string_1+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string_1+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"
cmake_string_2=${cmake_string_1}
cmake_string_1+=" -DENABLE_PYMOAB=OFF"
cmake_string_1+=" -DBUILD_SHARED_LIBS=OFF"
cmake_string_2+=" -DENABLE_PYMOAB=ON"
cmake_string_2+=" -DBUILD_SHARED_LIBS=ON"

${CMAKE} ../src ${cmake_string_1}
make -j${num_cpus}
make -j${num_cpus} install

${CMAKE} ../src ${cmake_string_2}
make -j${num_cpus}
make -j${num_cpus} install

cd ${install_prefix}
dirs="bin include lib/cmake lib/pkgconfig lib/python3.12/site-packages share/doc share/man/man1"
files="lib/*.a lib/libMOAB.so* lib/moab.make"
for d in ${dirs}; do
  mkdir -pv ${python_dir}/${d}
  ln -svf ${install_prefix}/${d}/* ${python_dir}/${d}
done
for f in ${files}; do
  ln -svf ${install_prefix}/${f} ${python_dir}/${f}
done
