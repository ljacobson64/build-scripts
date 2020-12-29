#!/bin/bash

set -e

export swig_version=4.0.2
export boost_version=1.72.0

build_prefix=${build_dir}/FRENSIE
install_prefix=${install_dir}/FRENSIE

if [ "${custom_python}" == "true" ]; then
  load_python2
fi

swig_dir=${install_dir}/swig-${swig_version}
boost_dir=${install_dir}/boost-${boost_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}
dagmc_dir=${install_dir}/DAGMC-moab-${moab_version}

if [ "$(hostname -s)" == "hpclogin2" ] && [ "${compiler}" == "gcc-9" ]; then
  module load openmpi/4.0.5-gcc930
  openmpi_dir=${EBROOTOPENMPI}
else
  openmpi_dir=${install_dir}/openmpi-${openmpi_version}
fi

distro_version="$(lsb_release -i -s)"-"$(lsb_release -r -s)"

# Reduce number of CPUS so there is at least 5 GB of memory per CPU
mem=`grep MemTotal /proc/meminfo`
arr=(${mem})
mem=${arr[1]}
num_cpus_frensie=$((mem / 5242880))
num_cpus_frensie=$((${num_cpus_frensie}<${num_cpus}?${num_cpus_frensie}:${num_cpus}))
echo ${num_cpus_frensie}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://github.com/FRENSIE/FRENSIE -b master --single-branch
ln -sv FRENSIE src
cd FRENSIE
sed -i 's/SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}\/lib")/SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${CMAKE_INSTALL_PREFIX}\/lib")/' CMakeLists.txt
cd ../bld

rpath_dirs="${openmpi_dir}/lib:${boost_dir}/lib:${hdf5_dir}/lib:${moab_dir}/lib:${dagmc_dir}/lib"
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs="${compiler_rpath_dirs}:${rpath_dirs}"
fi

cmake_string=
cmake_string+=" -DFRENSIE_ENABLE_DBC=OFF"
cmake_string+=" -DFRENSIE_ENABLE_PROFILING=OFF"
cmake_string+=" -DFRENSIE_ENABLE_COVERAGE=OFF"
cmake_string+=" -DFRENSIE_ENABLE_OPENMP=ON"
cmake_string+=" -DFRENSIE_ENABLE_COLOR_OUTPUT=ON"
cmake_string+=" -DFRENSIE_ENABLE_EXPLICIT_TEMPLATE_INST=ON"
cmake_string+=" -DFRENSIE_ENABLE_MANUAL=OFF"
cmake_string+=" -DFRENSIE_ENABLE_DASHBOARD_CLIENT=OFF"
cmake_string+=" -DFRENSIE_ENABLE_MPI=ON"
cmake_string+=" -DFRENSIE_ENABLE_HDF5=ON"
cmake_string+=" -DFRENSIE_ENABLE_MOAB=ON"
cmake_string+=" -DFRENSIE_ENABLE_DAGMC=ON"
cmake_string+=" -DFRENSIE_ENABLE_ROOT=OFF"
cmake_string+=" -DSWIG_EXECUTABLE=${swig_dir}/bin/swig"
cmake_string+=" -DMPI_PREFIX=${openmpi_dir}"
cmake_string+=" -DBOOST_PREFIX=${boost_dir}"
cmake_string+=" -DHDF5_PREFIX=${hdf5_dir}"
cmake_string+=" -DMOAB_PREFIX=${moab_dir}"
cmake_string+=" -DDAGMC_PREFIX=${dagmc_dir}"
cmake_string+=" -DXSDIR=${DATAPATH}/xsdir_mcnp6.2"
cmake_string+=" -DCMAKE_VERBOSE_CONFIGURE=OFF"
cmake_string+=" -DBUILDNAME_PREFIX=${distro_version}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

rm -f install.log
/usr/bin/time -v ${CMAKE} ../src ${cmake_string}                         2>&1 | tee -a install.log
/usr/bin/time -v make -j${num_cpus_frensie}                              2>&1 | tee -a install.log
/usr/bin/time -v ${sudo_cmd_install} make -j${num_cpus_frensie} install  2>&1 | tee -a install.log
