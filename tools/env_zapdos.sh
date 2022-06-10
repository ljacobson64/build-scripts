#!/bin/bash

source versions.sh


# Important directories
export dist_dir=/home/lucas/dist
export build_dir=/home/lucas/build
export install_dir=/opt/software

# Miscellaneous directories
export lapack_dir=/usr/lib/x86_64-linux-gnu            # SCALE
export mcnp_exe=${install_dir}/MCNP620/bin/mcnp5       # LAVA, ADVANTG
export DATAPATH=${install_dir}/MCNP620/MCNP_DATA       # FRENSIE
export scale_data_dir=${install_dir}/SCALE-6.2.3/data  # SCALE

# Miscellaneous environment variables
export num_cpus=`grep -c processor /proc/cpuinfo`
export custom_boost=false
export custom_eigen=false
export custom_exnihilo_packs=false
export custom_lapack=false
export custom_python=false
export system_has_java=true
export system_has_latex=true
export system_has_x11=true

# Specify location of CMake
export CMAKE=/usr/bin/cmake

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
  export compiler_rpath_dirs=
elif [ "${compiler}" == "gcc-9" ]; then
  :
  :
  :
  :
  :
  :
elif [ "${compiler}" == "intel" ]; then
  export intel_dir=/opt/intel/oneapi
  source ${intel_dir}/setvars.sh
  export CC=${intel_dir}/compiler/latest/linux/bin/intel64/icc
  export CXX=${intel_dir}/compiler/latest/linux/bin/intel64/icpc
  export FC=${intel_dir}/compiler/latest/linux/bin/intel64/ifort
  export compiler_rpath_dirs=${intel_dir}/compiler/latest/linux/compiler/lib/intel64
fi

# Control which versions of MCNP/DAGMC are built
if [ "${compiler}" == "native" ]; then
  export install_fludag=true
  export install_daggeant4=true
elif [ "${compiler}" == "gcc-9" ]; then
  export install_fludag=true
  export install_daggeant4=true
elif [ "${compiler}" == "intel" ]; then
  export install_fludag=false
  export install_daggeant4=false
fi

# Major python versions
export python2_version_major=2.7
export python3_version_major=3.8

# Functions to load python variables
load_python2() {
:
:
:
}
load_python3() {
:
:
:
}
