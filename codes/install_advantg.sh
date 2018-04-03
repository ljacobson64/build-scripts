#!/bin/bash

set -e

build_prefix=${build_dir}/advantg-${advantg_version}
install_prefix=${install_dir}/advantg-${advantg_version}

if [ "${native_exnihilo_packs}" != "true" ]; then
  pcre_dir=${install_dir}/pcre-${pcre_version}
  swig_dir=${install_dir}/swig-${swig_version}
  python_dir=${install_dir}/python-${python_version}
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
tarball=advantg-${advantg_version}.tar.gz
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv advantg src
cd advantg
sed -i "s/ADVANTG CXX Fortran/ADVANTG C CXX Fortran/" CMakeLists.txt

${sudo_cmd} mkdir -p ${install_prefix}/mgxs
cd ${install_prefix}/mgxs
${sudo_cmd} tar -xzvf ${dist_dir}/misc/mgxs.tar.gz

cd ${build_prefix}/bld

export CMAKE_PREFIX_PATH=
if [ "${native_exnihilo_packs}" != "true" ]; then
  export CMAKE_PREFIX_PATH+=:${pcre_dir}
  export CMAKE_PREFIX_PATH+=:${swig_dir}
  export CMAKE_PREFIX_PATH+=:${python_dir}
fi
export CMAKE_PREFIX_PATH+=:${openmpi_dir}
export CMAKE_PREFIX_PATH+=:${hdf5_dir}
export CMAKE_PREFIX_PATH+=:${silo_dir}
export CMAKE_PREFIX_PATH+=:${lava_dir}

cmake_string=
cmake_string+=" -DADVANTG_DEBUG=ON"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DMCNP_EXECUTABLE=${mcnp_exe}"
cmake_string+=" -DSCALE_DATA_DIR="
cmake_string+=" -DANISNLIB_SEARCH_PATH=${install_prefix}/mgxs"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DUSE_OPENMP=OFF"
cmake_string+=" -DDENOVO_IS_PARALLEL=ON"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make install
