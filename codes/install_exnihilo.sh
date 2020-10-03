#!/bin/bash

set -e

build_prefix=${build_dir}/exnihilo-${exnihilo_version}
install_prefix=${install_dir}/exnihilo-${exnihilo_version}

if [ "${native_exnihilo_packs}" == "false" ]; then
  pcre_dir=${install_dir}/pcre-${pcre_version}
  swig_dir=${install_dir}/swig-${swig_version}
  python_dir=${install_dir}/python-${python2_version}
fi
openmpi_dir=${install_dir}/openmpi-${openmpi_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
silo_dir=${install_dir}/silo-${silo_version}
lava_dir=${install_dir}/lava-${lava_version}

CC=${openmpi_dir}/bin/mpicc
CXX=${openmpi_dir}/bin/mpic++
FC=${openmpi_dir}/bin/mpifort

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=exnihilo-${exnihilo_version}.tar.gz
tar -xzvf ${dist_dir}/advantg/${tarball}
ln -sv Scale src
cd Scale
mv Exnihilo ..
ln -sv ../Exnihilo .
cd ..
git clone https://github.com/TriBITSPub/TriBITS -b master --single-branch
cd TriBITS
git checkout a24cefe7d538cc179111b1abc4279aee03282141
sed -i "s/FIND_PACKAGE(\${FIND_PythonInterp_ARGS})/FIND_PACKAGE(\${FIND_PythonInterp_ARGS} 2)/" tribits/core/package_arch/TribitsFindPythonInterp.cmake
cd ..
git clone https://github.com/trilinos/Trilinos  -b master --single-branch
cd bld

export CMAKE_PREFIX_PATH=
if [ "${native_exnihilo_packs}" == "false" ]; then
  export CMAKE_PREFIX_PATH+=:${pcre_dir}
  export CMAKE_PREFIX_PATH+=:${swig_dir}
  export CMAKE_PREFIX_PATH+=:${python_dir}
fi
export CMAKE_PREFIX_PATH+=:${openmpi_dir}
export CMAKE_PREFIX_PATH+=:${hdf5_dir}
export CMAKE_PREFIX_PATH+=:${silo_dir}
export CMAKE_PREFIX_PATH+=:${lava_dir}

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} -C ${build_prefix}/Exnihilo/install/codes/Exnihilo/for-advantg.cmake ${cmake_string} ../src
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install
