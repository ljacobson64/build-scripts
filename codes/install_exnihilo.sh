#!/bin/bash

set -e

build_prefix=${build_dir}/exnihilo-${exnihilo_version}
install_prefix=${install_dir}/exnihilo-${exnihilo_version}

if [ "${custom_python}" == "true" ]; then
  load_python2
fi

pcre_dir=${install_dir}/pcre-${pcre_version}
swig_dir=${install_dir}/swig-${swig_version}
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
tar -xzvf ${dist_dir}/advantg/TriBITS-a24cefe.tar.gz
ln -sv TriBITS-a24cefe TriBITS
sed -i "s/FIND_PACKAGE(\${FIND_PythonInterp_ARGS})/FIND_PACKAGE(\${FIND_PythonInterp_ARGS} 2)/" TriBITS/tribits/core/package_arch/TribitsFindPythonInterp.cmake
tar -xzvf ${dist_dir}/advantg/trilinos-release-13-0-1.tar.gz
ln -sv Trilinos-trilinos-release-13-0-1 Trilinos
cd bld

export CMAKE_PREFIX_PATH=
if [ "${custom_exnihilo_packs}" == "true" ]; then
  export CMAKE_PREFIX_PATH+=:${pcre_dir}
  export CMAKE_PREFIX_PATH+=:${swig_dir}
  export CMAKE_PREFIX_PATH+=:${python2_dir}
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
make -j${num_cpus}
make -j${num_cpus} install
