#!/bin/bash

set -e

build_prefix=${build_dir}/dakota-${dakota_version}
install_prefix=${install_dir}/dakota-${dakota_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
boost_dir=${install_dir}/boost-${boost_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=dakota-${dakota_version}-release-public.src-UI.tar.gz
url=https://dakota.sandia.gov/sites/default/files/distributions/public/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv dakota-${dakota_version}-release-public.src-UI src
cd dakota-${dakota_version}-release-public.src-UI
sed -i "s/COMPONENTS \"filesystem;program_options;regex;serialization;system\"/COMPONENTS filesystem;program_options;regex;serialization;system/" cmake/DakotaFindSystemTPLs.cmake
cd ../bld

if [ -n "${compiler_lib_dirs}" ]; then
  LD_LIBRARY_PATH=${compiler_lib_dirs}
fi

cmake_string=
cmake_string+=" -DDAKOTA_HAVE_MPI=TRUE"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DHAVE_QUESO=ON"
cmake_string+=" -DDAKOTA_HAVE_GSL=ON"
cmake_string+=" -DDAKOTA_HAVE_HDF5=ON"
cmake_string+=" -DHDF5_ROOT=${hdf5_dir}"
if [ "${native_boost}" == "false" ]; then
  cmake_string+=" -DBoost_NO_SYSTEM_PATHS=TRUE"
  cmake_string+=" -DBOOST_ROOT=${boost_dir}"
fi
if [ "${native_latex}" == "true" ]; then
  cmake_string+=" -DENABLE_DAKOTA_DOCS=TRUE"
else
  cmake_string+=" -DENABLE_DAKOTA_DOCS=FALSE"
fi
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

cmake ../src ${cmake_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install
